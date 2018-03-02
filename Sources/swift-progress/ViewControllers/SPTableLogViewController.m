//
//  SPTableLogViewController.m
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

#import "SPTableLogViewController.h"
#import "SPLineTableViewCell.h"
#import "SPStyleKit.h"
#import "SPLineItem.h"

#import "UXViewFactory.h"

@interface SPTableLogViewController () < NSTableViewDataSource,
                                         NSTableViewDelegate >
@end

@implementation SPTableLogViewController
{
  NSMutableArray<SPLineItem *> *arrangedObjects;
  NSTableView *tableView;
  NSIndexSet  *nullIS;
}

- (instancetype)init {
  if ((self = [super initWithNibName:nil bundle:nil]) != nil) {
    arrangedObjects = [NSMutableArray arrayWithCapacity:64];
    nullIS          = [NSIndexSet indexSetWithIndex:0];
  }
  return self;
}

- (NSTableView *)tableView {
  return self->tableView;
}


#pragma mark Input

- (void)handleLine:(NSString *)_line error:(BOOL)_flag {
  SPLineItem *item = [[SPLineItem alloc] initWithString:_line];
  if (item == nil) return;
  
  // this is weird
  dispatch_async(dispatch_get_main_queue(), ^{
    [self _handleItem:item];
  });
}

- (void)_handleItem:(SPLineItem *)item {
  NSUInteger sourceIdx = [arrangedObjects indexOfObjectPassingTest:
    ^BOOL(SPLineItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      if (obj->module == item->module)               return YES;
      if (obj->module == nil || item->module == nil) return NO;
      return [obj->module isEqualToString:item->module];
    }];
  NSUInteger viewIdx = sourceIdx == NSNotFound
               ? NSNotFound
               : (arrangedObjects.count - sourceIdx - 1);
  
  if (sourceIdx == NSNotFound) {
    [arrangedObjects addObject:item];
    [tableView insertRowsAtIndexes:nullIS
               withAnimation:NSTableViewAnimationSlideDown];
  }
  else {
    [arrangedObjects removeObjectAtIndex:sourceIdx];
    [arrangedObjects addObject:item];
    [tableView beginUpdates];
    [tableView moveRowAtIndex:viewIdx toIndex:0];
    [tableView endUpdates];
    
    [tableView reloadDataForRowIndexes:nullIS columnIndexes:nullIS];
  }
}

#pragma mark View Setup

- (void)loadView {
  NSScrollView *sv = [self.zz makeTableView:^(NSTableView *tv) {
    self->tableView = tv;
    
    /* datasource */
    tv.dataSource = self;
    tv.delegate   = self;
    
    tv.headerView = nil; // no header view

    tv.rowHeight  = 38; // TODO: automagic?
    
    tv.allowsColumnResizing    = NO;
    tv.allowsColumnSelection   = NO;
    tv.allowsEmptySelection    = YES; // show some info panel
    tv.allowsMultipleSelection = NO;
    tv.columnAutoresizingStyle = NSTableViewLastColumnOnlyAutoresizingStyle;
    
    tv.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    tv.gridColor     = [NSColor colorWithWhite:0.95 alpha:1.0];
    
    NSTableColumn *tc = [[NSTableColumn alloc] initWithIdentifier:@"line"];
    tc.editable     = NO;
    tc.resizingMask = NSTableColumnAutoresizingMask;
    [tv addTableColumn:tc];
    
    // seems to be necessary to make the column expand the whole width
    [tv sizeLastColumnToFit];
  }];
  
  sv.hasHorizontalScroller = NO;
  
  self.view = sv;
}

- (void)viewWillAppear {
  [super viewWillAppear];
  [self.tableView reloadData];
}


#pragma mark DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv {
  return arrangedObjects.count;
}

- (NSView *)tableView:(NSTableView *)tv viewForTableColumn:(NSTableColumn *)tc
            row:(NSInteger)row
{
  SPLineTableViewCell *v;
  SPLineItem *item = arrangedObjects[arrangedObjects.count - row - 1];
  // NSLog(@"view for item[%li]: %@", (long)row, item);
  
  if ((v = [tv makeViewWithIdentifier:@"line" owner:self]) == nil)
    v = [[SPLineTableViewCell alloc] initWithFrame:NSZeroRect];
  
  v.title    = item->module ?: @"?";

  if (item->itemType == SPLineItemTypeCompile) {
    if (item->sourceCount > 0) {
      v.subtitle =
        [NSString stringWithFormat:@"%li sources ...", (long)item->sourceCount];
    }
    else
      v.subtitle = item->line;
  }
  else
    v.subtitle = item->url ?: @"-";
  
  switch (item->itemType) {
    case SPLineItemTypeCompile:
      v.image = SPStyleKit.imageOfCompileDoneTVIcon;
      break;
    case SPLineItemTypeFetching:
      v.image = SPStyleKit.imageOfFetchingTVIcon2;
      break;
    case SPLineItemTypeCloning:
      v.image = SPStyleKit.imageOfCloningTVIcon2;
      break;
    case SPLineItemTypeResolving:
      v.image = SPStyleKit.imageOfResolvingTVIcon2;
      break;
    case SPLineItemTypeUpdating:
      v.image = SPStyleKit.imageOfFetchingTVIcon2;
      break;
  }
  
  return v;
}

#pragma mark Selection

- (NSIndexSet *)tableView:(NSTableView *)tv
                selectionIndexesForProposedSelection:(NSIndexSet *)_idxs
{
  return nil;
}

@end /* SPTableLogViewController */
