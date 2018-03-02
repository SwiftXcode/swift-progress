 //
//  CommandLineTask.m
//  swift-progress
//
//  Created by Helge Hess on 27.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

#import "CommandLineTask.h"

@implementation CommandLineTask
{
  NSString            *tool;
  NSArray<NSString *> *arguments;
  NSString            *shell;
  
  NSTask        *task;
  NSFileHandle  *fhOut;
  NSFileHandle  *fhErr;
  
  dispatch_queue_t outQ;
  
  NSMutableData *outLineBuffer;
  NSMutableData *errLineBuffer;
}

// TODO: The isStdErr flags do not make me happy.

- (dispatch_queue_t)exitQueue {
  return outQ;
}

- (instancetype)initWithTool:(NSString *)_tool
                arguments:(NSArray<NSString *> *)_args
{
  if ((self = [super init]) != nil) {
    self->tool         = [_tool copy];
    self->arguments    = [_args copy];
    self->_passThrough = YES;
    self->outQ         = dispatch_queue_create("de.zeezide.writer", NULL);
    self->shell        = [NSProcessInfo processInfo].environment[@"SHELL"];
  }
  return self;
}
- (instancetype)init {
  assert(NO);
  return nil;
}

- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  if (task != nil) {
    [nc removeObserver:self name:NSTaskDidTerminateNotification object:task];
  }
  [nc removeObserver:self name:NSFileHandleReadCompletionNotification
      object:nil];
}

- (void)run {
  // Maybe also do: https://stackoverflow.com/questions/4057985
  // (disable line buffering in child process, which might imply to
  //  not use NSTask, but well, that is no no-go).
  if ([self->_cwd length] > 0) {
    task.currentDirectoryPath = self.cwd;
  }
  
  assert(task == nil);
  task = [[NSTask alloc] init];
  
  NSMutableDictionary *env =
    [[NSProcessInfo processInfo].environment mutableCopy];
  env[@"NSUnbufferedIO"] = @"YES"; // Hm;
  task.environment = env;
  
  // do we need path lookup? Swift has a fixed location, but maybe
  // people use swift-env or sth.
  // https://stackoverflow.com/questions/208897/find-out-location-of-an-executable-file-in-cocoa
  if ([self->shell length] == 0) {
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:self->tool]) {
      NSLog(@"tool does not exist: %@", self->tool);
      exit(42 + 1);
    }
    
    task.launchPath = self->tool;
    task.arguments  = [self->arguments count] > 0 ? self->arguments : @[];
  }
  else {
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:self->shell]) {
      NSLog(@"shell does not exist: %@", self->shell);
      exit(42 + 1);
    }
    
    task.launchPath = self->shell; // just swift is no good
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:8];
    [args addObject:@"-c"];
#if 0
    [args addObject:self->tool];
    NSLog(@"ADD ARGS: %@", self->arguments);
    if ([self->arguments count] > 0) {
      [args addObject:self->tool]; // $0
      [args addObjectsFromArray:self->arguments];
    }
#else
    if ([self->arguments count] > 0) {
      // TODO: escaping
      NSString *bashArgs = [self->arguments componentsJoinedByString:@" "];
      [args addObject:[[self->tool stringByAppendingString:@" "]
                                   stringByAppendingString:bashArgs]];
    }
    else
      [args addObject:self->tool];
    #endif
    
    task.arguments = args;
  }
  
  task.standardOutput = [NSPipe pipe];
  task.standardError  = [NSPipe pipe];
  outLineBuffer = [NSMutableData dataWithCapacity:4096];
  errLineBuffer = [NSMutableData dataWithCapacity:4096];

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(onTaskTerminate:)
      name:NSTaskDidTerminateNotification object:nil];
  
#if 0
  // this dupes stuff. why? different FH, different FD.
  [nc addObserver:self selector:@selector(onDataRead:)
      name:NSFileHandleReadCompletionNotification object:fhOut];
  [nc addObserver:self selector:@selector(onDataRead:)
      name:NSFileHandleReadCompletionNotification object:fhErr];
#else // this fixes it, but it is still weird
  [nc addObserver:self selector:@selector(onDataRead:)
             name:NSFileHandleReadCompletionNotification object:nil];
#endif

  fhOut = [task.standardOutput fileHandleForReading];
  fhErr = [task.standardError  fileHandleForReading];
  [fhOut readInBackgroundAndNotify];
  [fhErr readInBackgroundAndNotify];
  
  [task launch];
}

- (void)checkDone {
  if (task.running) return;
  if (fhErr != nil || fhOut != nil) return;
#if DEBUG && 0
  NSLog(@"we are done!");
#endif

  [self flushBuffers:YES];

  if ([_delegate respondsToSelector:@selector(task:terminatedWithStatus:)])
    [_delegate task:self terminatedWithStatus:task.terminationStatus];
}

- (void)onTaskTerminate:(NSNotification *)n {
  assert(task == n.object);
  // NSLog(@"task did terminate: %@", n);
  [self checkDone];
}

- (void)onEOF:(NSFileHandle *)fh {
  BOOL isStdErr = fh == fhErr;

  // NSString *prefix  = isStdErr ? @"ERR:" : @"Out:";
  // NSLog(@"  %@READ EOF.", prefix);
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  if (fh == fhOut) {
    [nc removeObserver:self name:NSFileHandleReadCompletionNotification
                object:fhOut];
    fhOut = nil;
  }
  if (fh == fhErr) {
    [nc removeObserver:self name:NSFileHandleReadCompletionNotification
                object:fhErr];
    fhErr = nil;
  }
  
  [self checkDone];

  if (self->_passThrough) {
    dispatch_async(outQ, ^{
      FILE *fh = isStdErr ? stderr : stdout;
      fclose(fh);
    });
  }
}

- (void)onDataRead:(NSNotification *)n {
  if (fhOut != n.object && fhErr != n.object) { return; }
  
  BOOL   isStdErr = n.object == fhErr;
  NSData *data = n.userInfo[NSFileHandleNotificationDataItem];
  
  // sent twice? (maybe once w/ nil, once empty?)
  if ([data length] == 0) {
    [self onEOF:n.object];
    return;
  }
  
  // dupe on own
  if (self->_passThrough) {
    NSData *dc = [data copy]; // hmmm, it is potentially mutable
    dispatch_async(outQ, ^{ // TBD: sometimes this may be too late?
      FILE *fh = isStdErr ? stderr : stdout;
      //fwrite("<-\n", 3, 1, fh);
      fwrite(dc.bytes, dc.length, 1, fh);
      fflush(fh);
      //fwrite(">-\n", 3, 1, fh);
    });
  }
  
  NSMutableData *buffer = isStdErr ? errLineBuffer : outLineBuffer;
  #if DEBUG & 0
    NSLog(@"add data: %i to %@", [data length], buffer);
  #endif
  [buffer appendData:data];
  
  dispatch_async(dispatch_get_main_queue(), ^{ // coerce
    [self flushBuffers:NO];
  });
  
  [[n object] readInBackgroundAndNotify]; // continue
}

- (void)flushBuffers:(BOOL)final {
  // split buffer in lines, check whether there is an end
  // TODO: Ugly design, this should be in a buffer class to avoid the switch,
  //       but well ...
  
#if DEBUG & 0
  NSLog(@"buffer: %lu %lu",
        (unsigned long)outLineBuffer.length,
        (unsigned long)errLineBuffer.length);
#endif
  
  outLineBuffer = [[self processLinesInData:outLineBuffer isStdErr:NO]
                         mutableCopy];
  errLineBuffer = [[self processLinesInData:errLineBuffer isStdErr:YES]
                         mutableCopy];
  
  // those are not necessarily terminated by a NL
  if (final) {
    if (outLineBuffer.length > 0)
      [self handleDataLine:outLineBuffer isStdErr:NO];
    outLineBuffer = nil;
    
    if (errLineBuffer.length > 0)
      [self handleDataLine:errLineBuffer isStdErr:YES];
    errLineBuffer = nil;
  }
}

- (void)handleDataLine:(NSData *)_line isStdErr:(BOOL)_isStdErr {
  NSString *s = [[NSString alloc] initWithData:_line
                                  encoding:NSUTF8StringEncoding];
  if (_isStdErr)
    [self->_delegate task:self receivedLineOnStdErr:s];
  else
    [self->_delegate task:self receivedLineOnStdOut:s];

}

- (NSData *)processLinesInData:(NSData *)_data isStdErr:(BOOL)_isStdErr {
  unsigned long len = [_data length], index = 0, lastSepIdx = 0;
  
  unsigned char cData[len]; // Hmmm. A lot of stack potentially.
  [_data getBytes:cData length:len];
  
  BOOL report = [self->_delegate respondsToSelector:_isStdErr
                                   ? @selector(task:receivedLineOnStdErr:)
                                   : @selector(task:receivedLineOnStdOut:)];
  
  do {
    if (cData[index] == '\n') {
      NSRange   r    = NSMakeRange(lastSepIdx, index - lastSepIdx);
      
      if (report) {
        [self handleDataLine:[_data subdataWithRange:r] isStdErr:_isStdErr];
      }
      
      lastSepIdx = index + 1;
      continue;
    }
  } while (index++ < len);
  
  if (lastSepIdx < len) {
    NSRange r = NSMakeRange(lastSepIdx, len - lastSepIdx);
    return [_data subdataWithRange:r];
  }
  
  return [NSData data];
}

@end /* CommandLineTask */
