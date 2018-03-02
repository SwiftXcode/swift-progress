//
//  AppDelegate.m
//  swift-progress
//
//  Created by Helge Hess on 26.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

@import Cocoa;

#import "AppDelegate.h"
#import "SPWindowController.h"
#import "CommandLineTask.h"

@interface AppDelegate() < CommandLineTaskDelegate >
@end

@implementation AppDelegate
{
  SPWindowController *mainWC;
  CommandLineTask    *task;
  int                exitStatus;
  NSDate             *startDate;
  BOOL               didShowWindow;
  NSTimeInterval     windowShowDelay;
}

- (instancetype)init {
  if ((self = [super init]) != nil) {
    exitStatus      = 0;
    didShowWindow   = NO;
    startDate       = [NSDate date];
    windowShowDelay = 2; // clean `swift build` takes 2-3s for me!
    
    mainWC = [SPWindowController new];
    
    NSProcessInfo *pi = [NSProcessInfo processInfo];
    NSArray *ownArgs  = pi.arguments;
    if ([ownArgs count] < 2) {
      NSLog(@"invalid number of arguments: %@", ownArgs);
      exit(42);
    }
    
    NSString *tool = ownArgs[1];
    NSArray<NSString *> *args = [ownArgs subarrayWithRange:
                                           NSMakeRange(2, ownArgs.count - 2)];
    task = [[CommandLineTask alloc] initWithTool:tool arguments:args];
    task.delegate    = self;
    task.passThrough = YES;
  }
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  assert(mainWC.window != nil);
#if DEBUG && 1 // don't
  [self _showWindowIfNecessary];
#endif
  [task run];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  NSLog(@"app will terminate: %i", exitStatus);
  if (exitStatus != 0) {
    dispatch_sync(task.exitQueue, ^() {
      // Funky hack. Make sure all writes we spooled up have been delivered.
      exit(exitStatus);
    });
  }
}


- (void)task:(CommandLineTask * _Nonnull)_task
        terminatedWithStatus:(int)_status
{
  // NSLog(@"Task done: %i", _status);
  exitStatus = _status;
  
  // FIXME: need to exit immediately, so that we don't block Xcode.
  #if DEBUG && 1
    [NSTimer scheduledTimerWithTimeInterval:50
             target:NSApp selector:@selector(terminate:)
             userInfo:nil repeats:NO];
  #else
    [NSApp terminate:nil];
  #endif
}

- (void)_showWindowIfNecessary {
  if (didShowWindow) return;
  didShowWindow = YES;
  

  [NSTimer scheduledTimerWithTimeInterval:windowShowDelay
           repeats:NO block:^(NSTimer * _Nonnull timer) {
    [mainWC showWindow:self];
    //[mainWC.window orderFront:nil];
    [mainWC fadeInAndRun:nil];
  }];
}

- (void)task:(CommandLineTask * _Nonnull)_task
        receivedLineOnStdOut:(NSString * _Nonnull)_line
{
  // NSLog(@"Out: %@", _line);
  [self _showWindowIfNecessary];
  [mainWC handleLine:_line error:NO];
}
- (void)task:(CommandLineTask * _Nonnull)_task
        receivedLineOnStdErr:(NSString * _Nonnull)_line
{
  //NSLog(@"ERR: %@", _line);
  [self _showWindowIfNecessary];
  [mainWC handleLine:_line error:YES];
}

@end
