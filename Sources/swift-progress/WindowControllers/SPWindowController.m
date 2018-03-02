//
//  SPWindowController.m
//  swift-progress
//
//  Created by Helge Hess on 27.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

#import "SPWindowController.h"
#import "SPTabViewController.h"
#import "UXToolbarStatusView.h"
#import "SPStyleKit.h"

@interface SPWindowController ()

@end

@implementation SPWindowController
{
  SPTabViewController *tabVC;
  BOOL didTaskTerminate;
  int  exitCode;
  UXToolbarStatusView *statusView;
}

- (instancetype)init {
  if ((self = [super init]) != nil) {
    self.mainComponentName         = @"SPTabViewController";
    self.zzFrameAutosaveName       =
           @"de.zeezide.swiftxcode.spm.app.main.win.frame";
    self.title                     = @"SwiftXcode";
    self.zzToolbarID               =
           @"de.zeezide.swiftxcode.spm.app.main.win.toolbar";
    
    self.defaultMinimumSize        = NSMakeSize(270, 120);
    self.defaultWindowContentSize  = NSMakeSize(270, 320);

    // This is very fishy, but hey!
    didTaskTerminate = NO;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onTaskTerminate:)
               name:NSTaskDidTerminateNotification object:nil];
  }
  return self;
}
- (void)dealloc {
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self name:NSTaskDidTerminateNotification object:nil];
}

- (void)onTaskTerminate:(NSNotification *)n {
  didTaskTerminate = YES;
  
  NSTask *task = [n object];
  exitCode = [task terminationStatus];
  
  [self updateStatusView];
}

- (BOOL)hasUnifiedTitleAndToolbar {
  return YES;
}

- (NSUInteger)defaultWindowStyleMask {
  NSUInteger styleMask = [super defaultWindowStyleMask];
  styleMask -= NSWindowStyleMaskMiniaturizable;
  return styleMask;
}

- (__kindof NSViewController *)createContentViewController {
  return (tabVC = [[SPTabViewController alloc] init]); // hacky
}

- (void)applyInitialWindowPosition:(NSWindow *)win {
  NSRect  screenFrame = [NSScreen mainScreen].visibleFrame;
  NSRect  ourFrame    = win.frame;
  NSPoint pos;
  
  pos.x = 0;
  pos.y = screenFrame.origin.y + screenFrame.size.height
        - ourFrame.size.height;
  [win setFrameOrigin:pos];
}


#pragma mark Input

- (SPTabViewController *)tabVC {
  SPTabViewController *tvc = (SPTabViewController *)
                                self.window.contentViewController;
  assert(tvc != nil);
  return tvc;
}

- (void)handleLine:(NSString *)_line error:(BOOL)_flag {
  [tabVC handleLine:_line error:_flag];
}


#pragma mark Toolbar

- (void)loadToolbar {
  [super loadToolbar];
  [self.window.toolbar setSelectedItemIdentifier:@"table"];
  self.window.toolbar.displayMode = NSToolbarDisplayModeIconOnly;
  self.window.toolbar.allowsUserCustomization = NO;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)_tb {
  return @[ @"progress",
            @"rawlog", @"table" ];
}
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)_tb {
  return [self toolbarDefaultItemIdentifiers:_tb];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)_tb
                   itemForItemIdentifier:(NSString *)_iid
                   willBeInsertedIntoToolbar:(BOOL)_isOn
{
  /* setup item */
  
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:_iid];
  
  if ([_iid isEqualToString:@"table"]) {
    item.label        = @"Results";
    item.paletteLabel = item.label;
    item.target = self;
    item.action = @selector(switchTabs:);
    item.image  = SPStyleKit.imageOfTableTBImage;
  }
  else if ([_iid isEqualToString:@"rawlog"]) {
    item.label        = @"Raw Log";
    item.paletteLabel = item.label;
    item.target = self;
    item.action = @selector(switchTabs:);
    item.image  = SPStyleKit.imageOfRawTBImage;
  }
  else if ([_iid isEqualToString:@"stop"]) {
    item.label        = @"Stop!";
    item.paletteLabel = item.label;
    item.target = self;
    item.action = @selector(stop:);
    // TODO: item.image
  }
  else if ([_iid isEqualToString:@"progress"]) {
    item.label        = @"Progress";
    item.paletteLabel = item.label;
    item.view         = [self makeStatusView];
    item.minSize      = NSMakeSize(100,  25);
    item.maxSize      = NSMakeSize(1000, 25);
    item.visibilityPriority = 0;
  }
  
  return item;
}

- (NSView *)makeStatusView {
  if (statusView != nil) return statusView;
  
  statusView =
      [[UXToolbarStatusView alloc] initWithFrame:NSMakeRect(0, 0, 180, 25)];
  
  statusView.translatesAutoresizingMaskIntoConstraints = YES;
  statusView.autoresizingMask = NSViewWidthSizable;
  
  [statusView setContentHuggingPriority:10
              forOrientation:NSLayoutConstraintOrientationHorizontal];

  [self updateStatusView];
  return statusView;
}
- (void)updateStatusView {
  if (!didTaskTerminate) {
    statusView.textField.stringValue = @"Packaging ...";
    [statusView.spinner startAnimation:nil];
  }
  else {
    if (exitCode == 0)
      statusView.textField.stringValue = @"SPM Finished.";
    else
      statusView.textField.stringValue = @"SPM failed.";
    [statusView.spinner stopAnimation:nil];
  }
}


#pragma mark Actions

- (void)stop:(id)_sender {
  // just exit
  [self fadeOutAndRun:^{
    exit(42 + 10);
  }];
}

- (void)switchTabs:(id)_sender {
  if (![_sender isKindOfClass:[NSToolbarItem class]])
    return;
  
  NSToolbarItem *tbi = (__typeof(tbi))_sender;
  NSTabView     *tv  = tabVC.tabView;
  [tv selectTabViewItemWithIdentifier:tbi.itemIdentifier];
}

@end
