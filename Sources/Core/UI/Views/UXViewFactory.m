//
//  ZzViewControllerFactory.m
//  swift-progress
//
//  Created by Helge Hess on 27.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

#import "UXViewFactory.h"

#define ZZInitialSize (NSMakeRect(0, 0, 128, 128))

@implementation UXViewFactory

+ (UXViewFactory *)defaultViewFactory {
  static dispatch_once_t once;
  static id singleton;
  dispatch_once(&once, ^{ singleton = [[self alloc] init]; });
  return singleton;
}

- (__kindof UXView *)make:(Class)_class with:(void (^)(__kindof UXView *))block{
  UXView *v = [[_class alloc] initWithFrame:ZZInitialSize];
  v.translatesAutoresizingMaskIntoConstraints = NO;
  block(v);
  return v;
}

- (UXLabel *)makeLabel:(id)value {
  NSTextField *v = [[NSTextField alloc] initWithFrame:ZZInitialSize];
  v.translatesAutoresizingMaskIntoConstraints = NO;
  
  /* configure as label */
  v.editable        = NO;
  v.bezeled         = NO;
  v.drawsBackground = NO;
  v.selectable      = NO; // not for raw labels
  
  /* common */
  v.alignment   = NSTextAlignmentLeft;
  v.objectValue = value; // TODO: formatters
  
#if 1
  // for NSTextField. There is also fittingSize, intrinsicContentSize,
  // but those don't work for NSTextField?
  // fittingSize considers all child views
  [v sizeToFit]; // hm. still required?
#endif
  
  return v;
}

- (NSProgressIndicator *)makeSpinner {
  NSProgressIndicator *v;
  
  v = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0,0,16,16)];
  v.translatesAutoresizingMaskIntoConstraints = NO;
  
  v.indeterminate        = YES;
  v.displayedWhenStopped = NO;
  v.bezeled              = NO;
  v.controlSize          = NSControlSizeSmall;
  v.style                = NSProgressIndicatorSpinningStyle;
  
  return v;
}

- (UXScrollView *)makeTableView:(void (^)(NSTableView *view))block {
  UXScrollView *sv = [self makeTableView];
  block((NSTableView *)sv.documentView);
  return sv;
}

- (UXScrollView *)makeTableView {
  // embed in scroll view, should always be done for tableviews.
  // Note: translatesAutoresizingMaskIntoConstraints is ON!
  NSTableView  *tv = [[NSTableView  alloc] initWithFrame:ZZInitialSize];
  return [self makeScrollView:tv];
}

- (UXScrollView *)makeScrollView:(UXView *)nestedView {
  NSScrollView *sv = [[NSScrollView alloc] initWithFrame:ZZInitialSize];
  // Note: translatesAutoresizingMaskIntoConstraints is ON!
  
  sv.usesPredominantAxisScrolling = NO;  // YES by default
  sv.autohidesScrollers           = YES; // default NO
  sv.hasHorizontalScroller        = YES;
  sv.hasVerticalScroller          = YES;
  sv.documentView                 = nestedView;
  
  return sv;
}

- (UXView *)makeTextView:(void (^)(UXTextView *))block {
  NSScrollView *sv = (__typeof(sv))[self makeTextView];
  block(sv.documentView);
  return sv;
}

- (UXView *)makeTextView {
  NSScrollView *sv = [[UXScrollView alloc] initWithFrame:NSZeroRect];
  NSTextView   *cv = [self makeRawTextView];

  sv.translatesAutoresizingMaskIntoConstraints = NO;
  
  sv.usesPredominantAxisScrolling = NO;
  sv.autohidesScrollers           = YES;
  sv.hasHorizontalScroller        = YES;
  sv.hasVerticalScroller          = YES;
  sv.documentView                 = cv;
  
  return sv;
}
- (NSTextView *)makeRawTextView {
  NSTextView *v = [[NSTextView alloc] initWithFrame:NSZeroRect];
  v.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
  return v;
}

- (UXView *)makeGenericView {
  NSView *v = [[NSView alloc] initWithFrame:ZZInitialSize];
  v.translatesAutoresizingMaskIntoConstraints = NO;
  return v;
}

- (UXView *)makeVisualEffectsSeeThroughContainer {
  // root view
  Class vibrantClass = NSClassFromString(@"NSVisualEffectView");
  if (vibrantClass == nil) // return a regular container for pre-Yosemite
    return [self makeGenericView];
  
  NSVisualEffectView *vibrant =
    [[vibrantClass alloc] initWithFrame:ZZInitialSize];
  [vibrant setWantsLayer:YES];
  [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
  return vibrant;
}

@end

@implementation NSViewController(Zz)
- (UXViewFactory *)zz {
  return [UXViewFactory defaultViewFactory];
}
@end
