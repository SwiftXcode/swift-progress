//
//  SPTabViewController.m
//  swift-progress
//
//  Created by Helge Hess on 27.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

#import "SPTabViewController.h"
#import "SPTableLogViewController.h"
#import "SPRawLogViewController.h"
#import "UXViewFactory.h"

@interface SPTabViewController() < NSTabViewDelegate >
@end

@implementation NSTabView(spVCs)
- (void)spAddViewController:(NSViewController *)vc identifier:(NSString *)_id {
  NSTabViewItem *item = [NSTabViewItem tabViewItemWithViewController:vc];
  item.identifier = _id;
  [self addTabViewItem:item];
  item.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  item.view.translatesAutoresizingMaskIntoConstraints = YES;
}
@end

@implementation SPTabViewController
{
  SPTableLogViewController *tableLogVC;
  SPRawLogViewController   *rawLogVC;
}

#pragma mark Input

- (void)handleLine:(NSString *)_line error:(BOOL)_flag {
  [tableLogVC handleLine:_line error:_flag];
  [rawLogVC   handleLine:_line error:_flag];
}


#pragma mark View Setup

- (void)loadView {
  // TBD: Doesn't actually work, maybe we need to wrap that in
  //      yet another view? Or make the children non-opaque?
  self.view = [self.zz makeVisualEffectsSeeThroughContainer];
  
  NSView *tv = [self.zz make:[NSTabView class] with:^(NSView *_sv) {
    NSTabView *tv = (__typeof(tv))_sv;
    
    tv.tabViewType = NSNoTabsNoBorder;
    tv.delegate    = self;
    
    tableLogVC = [SPTableLogViewController new];
    [tv spAddViewController:tableLogVC identifier:@"table"];
    
    rawLogVC = [SPRawLogViewController new];
    [tv spAddViewController:rawLogVC identifier:@"rawlog"];
    
    [tv selectFirstTabViewItem:nil];
  }];
  
  tv.translatesAutoresizingMaskIntoConstraints = YES;
  tv.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);

  [self.view addSubview:tv];
}


// MARK: - TabView support

- (void)tabView:(NSTabView *)tv didSelectTabViewItem:(NSTabViewItem *)item {
  [self sizeActiveTabView];
}

- (NSTabView *)tabView {
  if (!self.isViewLoaded) return nil;
  
  if ([self.view isKindOfClass:[NSTabView class]])
    return (NSTabView *)self.view;
  
  for (NSView *c in self.view.subviews) {
    if ([c isKindOfClass:[NSTabView class]])
      return (NSTabView *)c;
  }
  return nil;
}

- (void)viewWillAppear {
  [super viewWillAppear];
  [self sizeActiveTabView];
}

- (void)viewDidLayout {
  [super viewDidLayout];
  [self sizeActiveTabView];
}

- (void)sizeActiveTabView {
  NSTabView *tv = self.tabView;
  NSView    *cv = tv.selectedTabViewItem.view;
  
  cv.frame = tv.contentRect;
  cv.needsLayout = YES;
}

@end /* SPTabViewController */

