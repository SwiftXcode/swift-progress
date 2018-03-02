//
//  UXWindowController.m
//  Core
//
//  Created by Helge Heß on 1/15/16.
//
//

#import "UXWindowController.h"
//#import "NSViewController+Zz.h"

@implementation UXWindowController

+ (__kindof UXWindowController *)windowForVC:(NSString *)_vc {
  UXWindowController *wc = [self new];
  wc.mainComponentName = _vc;
  return wc;
}
+ (__kindof UXWindowController *)panelForVC:(NSString *)_vc {
  UXWindowController *wc = [self windowForVC:_vc];
  wc.zzWindowClass = [NSPanel class];
  return wc;
}

- (instancetype)init {
  if ((self = [self initWithWindowNibName:@"FAKE"]) != nil) {
    // only this triggers the load
    self->_mainComponentName         = @"ZzLoremVC";
    self->_defaultMinimumSize        = NSMakeSize(720, 340);
    self->_defaultWindowContentSize  = NSMakeSize(1000, 620);
    self->_hasUnifiedTitleAndToolbar = NO;
    self->_zzWindowClass             = [NSWindow class];
  }
  return self;
}

- (NSRect)defaultWindowContentRect {
  NSSize s = self.defaultWindowContentSize;
  NSRect contentRect = NSMakeRect(0, 200, s.width, s.height);
  return contentRect;
}

- (NSString *)title {
  if (self->_title != nil)
    return self->_title;
  
  NSString *cn = NSStringFromClass([self class]);
  NSLog(@"WC subclass %@ should override: %@", cn, NSStringFromSelector(_cmd));
  return cn;
}

- (NSUInteger)defaultWindowStyleMask {
  NSUInteger styleMask = ( NSWindowStyleMaskTitled
                         | NSWindowStyleMaskClosable
                         | NSWindowStyleMaskMiniaturizable
                         | NSWindowStyleMaskResizable);
  if (self.hasUnifiedTitleAndToolbar)
    styleMask |= NSWindowStyleMaskUnifiedTitleAndToolbar;
  return styleMask;
}

- (void)loadWindow {
  // NOTE: Not called if we invoke the view controller with -initWithWindow: ..
  //[super loadWindow]; // this just tries to load the nib
  
  if (self.document != nil)
    [self.document windowControllerWillLoadNib:self];
  
  /* alloc window and controller */
  
  NSWindow *win = [[self.zzWindowClass alloc] initWithContentRect:
                                      self.defaultWindowContentRect
                                    styleMask: self.defaultWindowStyleMask
                                    backing:   NSBackingStoreBuffered
                                    defer:     YES]; // TBD: defer
  win.title   = self.title;
  win.minSize = self.defaultMinimumSize;
  self.window = win;
  
  [self loadToolbar];
  
  if (win.styleMask & NSWindowStyleMaskUnifiedTitleAndToolbar)
    self.window.titleVisibility = NSWindowTitleHidden;

  
  // CREATE OUR ROOT VIEW CONTROLLER
  
  NSViewController *vc = [self createContentViewController];
  win.contentViewController = vc;
  
  
  /// Window size

  win.contentSize = self.defaultWindowContentSize;
  
  [self applyInitialWindowPosition:win];

  // autosave frame
  // Note: this stores the position, but not the size. The size is then reset
  //       by the contentViewController!
  // NOTE: this must be done late, so that it properly restores the size
  NSString *s = self.zzFrameAutosaveName;
  if (s.length > 0)
    win.frameAutosaveName = s;

  
  // notify the document, if there is one.
  if (self.document != nil)
    [self.document windowControllerDidLoadNib:self];
}

- (void)applyInitialWindowPosition:(NSWindow *)win {
  [win center];
}

- (__kindof NSViewController *)createContentViewController {
  return [[NSClassFromString(self.mainComponentName) alloc] init];
}


#pragma mark Toolbar

- (CGFloat)toolbarButtonHeight {
  return 24.0;
}

- (void)loadToolbar {
  NSString *tid = self.zzToolbarID;
  if (tid.length < 1)
    return;

  self->tb = [[NSToolbar alloc] initWithIdentifier:tid];
  self->tb.autosavesConfiguration  = NO;
  self->tb.allowsUserCustomization = NO;
  self->tb.delegate                = self;
  
  self.window.toolbar = self->tb;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)_tb {
  return @[];
}
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)_tb {
  return [self toolbarDefaultItemIdentifiers:_tb];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)tb
                   itemForItemIdentifier:(NSString *)iid
                   willBeInsertedIntoToolbar:(BOOL)flag
{
  NSLog(@"%@: subclass should override this if it has a toolbar!",
        NSStringFromSelector(_cmd));
  return nil;
}

- (NSToolbarItem *)makeToolbarItem:(NSString *)_iid
                   title:(NSString *)_buttonTitle image:(id)_image
                   action:(SEL)_action
                   keyEquivalent:(NSString *)_k
{
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:_iid];
  NSButton *b = [self makeToolbarButton:_buttonTitle image:_image
                      action:_action keyEquivalent:_k];
  item.label        = b.title;
  item.paletteLabel = b.title;
  item.view         = b;
  return item;
}

- (NSButton *)makeToolbarButton:(NSString *)_buttonTitle image:(id)_image
              action:(SEL)_action
              keyEquivalent:(NSString *)_k
{
  // 39x24 is the Xcode size
  // Sierra bug?:
  //   http://stackoverflow.com/questions/39768476/nstoolbaritem-make-sure-this-toolbar-item-has-a-valid-frame-min-max-size
  NSRect   f  = NSMakeRect(0,0, 39, self.toolbarButtonHeight);
  NSButton *b = [[NSButton alloc] initWithFrame:f];
  b.title         = _buttonTitle;
  b.target        = self;
  b.action        = _action;
  b.bezelStyle    = NSTexturedRoundedBezelStyle;
  if (_k != nil) {
    b.keyEquivalent             = _k;
    b.keyEquivalentModifierMask = NSEventModifierFlagCommand;
  }
  
  if (_image != nil) {
    b.imagePosition = NSImageOnly;
    
    if ([_image isKindOfClass:[NSString class]])
      b.image = [NSImage imageNamed:_image];
    else
      b.image = _image;
  }
  else {
    b.imagePosition = NSNoImage; // NSImageOnly;
    [b sizeToFit];
    f.size.width = b.frame.size.width;
    b.frame = f;
  }
  return b;
}


#pragma mark Fading

- (void)fadeOutAndRun:(void (^)(void))_done {
  [NSAnimationContext beginGrouping];
  {
    NSAnimationContext *ctx = [NSAnimationContext currentContext];
    __block __unsafe_unretained NSWindow *bself = self.window;
    ctx.duration = 0.5;
    ctx.completionHandler = ^{
      [bself orderOut:nil];
      bself.alphaValue = 1.f;
      _done();
    };
    bself.animator.alphaValue = 0.f;
  }
  [NSAnimationContext endGrouping];
}

- (void)fadeInAndRun:(void (^)(void))_done {
  // FIXME: doesn't actually fade-in. (fade-out works)
  self.window.animator.alphaValue = 0.f;
  [self.window orderFront:nil];

  [NSAnimationContext beginGrouping];
  {
    NSAnimationContext *ctx = [NSAnimationContext currentContext];
    ctx.duration = 1;
    self.window.animator.alphaValue = 1.f;
  }
  [NSAnimationContext endGrouping];
}


@end /* UXWindowController */
