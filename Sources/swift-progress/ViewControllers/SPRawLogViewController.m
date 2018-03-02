//
//  SPRawLogViewController.m
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

#import "SPRawLogViewController.h"
#import "UXViewFactory.h"

@interface SPRawLogViewController ()
@end

@implementation SPRawLogViewController
{
  NSFont       *font;
  NSDictionary *attributes;
  NSDictionary *errorAttributes;
}

- (void)loadView {
  NSColor *errColor = [NSColor colorWithRed:0.61 green:0.15 blue:0.32 alpha:1.0];
  font            = [NSFont userFixedPitchFontOfSize:14];
  attributes      = @{ NSFontAttributeName: font };
  errorAttributes = @{ NSFontAttributeName: font,
                       NSForegroundColorAttributeName: errColor };

  self.view = [self.zz makeTextView:^(NSTextView *tv) {
    tv.editable = NO;
    tv.richText = NO;
  }];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.textView.font = font;
}

- (NSScrollView *)scrollView {
  return (NSScrollView *)self.view;
}
- (NSTextView *)textView {
  return (NSTextView *)self.scrollView.documentView;
}

#pragma mark Input

- (void)handleLine:(NSString *)s error:(BOOL)_isError {
  NSAttributedString *as;
  
  s = [s stringByAppendingString:@"\n"];
  as = [[NSAttributedString alloc]
          initWithString:s attributes:_isError ? errorAttributes : attributes];
  
  NSTextView *tv = self.textView;
  [tv.textStorage appendAttributedString:as];
  [tv scrollRangeToVisible:NSMakeRange(tv.string.length, 0)];
}

@end /* SPRawLogViewController */
