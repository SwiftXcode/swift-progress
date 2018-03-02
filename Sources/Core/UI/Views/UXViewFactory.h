//
//  ZzViewControllerFactory.h
//  swift-progress
//
//  Created by Helge Hess on 27.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

@import Cocoa;

typedef NSView              UXView;
typedef NSTextField         UXLabel;
typedef NSProgressIndicator UXSpinner;
typedef NSScrollView        UXScrollView;
typedef NSTableView         UXTableView;
typedef NSImage             UXImage;
typedef NSImageView         UXImageView;
typedef NSColor             UXColor;
typedef NSTextView          UXTextView;

@interface UXViewFactory : NSObject

+ (UXViewFactory *)defaultViewFactory;

- (__kindof UXView *)make:(Class)_class with:(void (^)(__kindof UXView *))block;

- (UXLabel      *)makeLabel:(id)value;
- (UXSpinner    *)makeSpinner;
- (UXScrollView *)makeTableView:(void (^)(NSTableView *view))block;
- (UXView       *)makeTextView:(void (^)(UXTextView *))block;
- (UXView       *)makeTextView;
- (UXView       *)makeVisualEffectsSeeThroughContainer;

@end

@interface NSViewController(Zz)
- (UXViewFactory *)zz;
@end

