//
//  UXWindowController.h
//  ZeeCore
//
//  Created by Helge Heß on 1/15/16.
//
//

#import <Cocoa/Cocoa.h>

@interface UXWindowController : NSWindowController < NSToolbarDelegate >
{
  NSToolbar *tb;
}

+ (__kindof UXWindowController *)panelForVC:(NSString *)_vc;
+ (__kindof UXWindowController *)windowForVC:(NSString *)_vc;

@property (nonatomic, copy)     NSString   *mainComponentName;

@property (nonatomic)           NSSize     defaultWindowContentSize;
@property (nonatomic)           NSSize     defaultMinimumSize;

@property (nonatomic, readonly) BOOL       hasUnifiedTitleAndToolbar;
@property (nonatomic, copy)     NSString   *title;
@property (nonatomic)           NSUInteger defaultWindowStyleMask;

@property (nonatomic, copy)     NSString   *zzFrameAutosaveName;
@property (nonatomic, copy)     NSString   *zzToolbarID;
@property (nonatomic, readonly) CGFloat    toolbarButtonHeight;

@property (nonatomic)           Class      zzWindowClass;

- (__kindof NSViewController *)createContentViewController;

- (NSToolbarItem *)makeToolbarItem:(NSString *)_iid
                   title:(NSString *)_buttonTitle image:(id)_image
                   action:(SEL)_action
                   keyEquivalent:(NSString *)_k;

- (NSButton *)makeToolbarButton:(NSString *)_buttonTitle image:(id)_image
              action:(SEL)_action
              keyEquivalent:(NSString *)_k;

- (void)loadToolbar;

- (void)fadeOutAndRun:(void (^)(void))_done;
- (void)fadeInAndRun:(void (^)(void))_done;

@end
