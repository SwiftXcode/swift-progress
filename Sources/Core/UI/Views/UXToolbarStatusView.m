//
//  UXToolbarStatusView.m
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2016-2018 ZeeZide. All rights reserved.
//

@import QuartzCore;

#import "UXToolbarStatusView.h"
#import "UXViewFactory.h"

@implementation UXToolbarStatusView
{
  NSTextField         *_tf;
  NSImageView         *_iv;
  NSProgressIndicator *_pi;
  
  NSUInteger spinnerCount;
}

const CGFloat ZZToolbarCornerRadius = 4.0;

+ (BOOL)requiresConstraintBasedLayout {
  return YES;
}

- (NSColor *)bottomColor {
  return [NSColor colorWithCalibratedRed:0.929 green:0.929 blue:0.929 alpha:1];
}
- (NSColor *)topColor {
  return [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
}

- (id)initWithFrame:(NSRect)frameRect {
  if ((self = [super initWithFrame:frameRect])) {
    self.wantsLayer          = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius  = ZZToolbarCornerRadius;
    self.layer.borderWidth   = 0.5;
    self.layer.borderColor   = [NSColor lightGrayColor].CGColor;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.colors = @[(id)self.topColor.CGColor,(id)self.bottomColor.CGColor];
    gradient.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
    [self.layer addSublayer:gradient];
    
    [self _zzCreateSubviews];
    [self _zzCreateConstraints];
  }
  return self;
}
- (id)init {
  // 23 seems to be right, not sure. 26 is better for small spinner
  // return [self initWithFrame:NSMakeRect(0, 0, 320, 26)];
  // Xcode 8b size is 24px - also, buttons are always 24px high!
  // 25 seems to align properly with buttons.
  return [self initWithFrame:NSMakeRect(0, 0, 320, 25)];
}

- (NSProgressIndicator *)makeProgressIndicator {
  NSProgressIndicator *v;
  
  v = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0,0,42,42)];
  v.translatesAutoresizingMaskIntoConstraints = NO;
  
  v.indeterminate        = YES;
  v.displayedWhenStopped = NO;
  v.bezeled              = NO;
  v.controlSize          = NSControlSizeSmall; // NSMiniControlSize;
  v.style                = NSProgressIndicatorBarStyle;
  
  return v;
}

- (void)_zzCreateSubviews {
  #if 0
  self->_iv = [[NSImageView alloc] initWithFrame:ZZInitialSize];
  self->_iv.translatesAutoresizingMaskIntoConstraints = NO;
  #endif
  
  // @"ZeeCore  |  Build ZeeCore: Succeeded"
  UXViewFactory *vf = [UXViewFactory defaultViewFactory];
  self->_tf = [vf makeLabel:@""];
  
  self->_tf.cell.lineBreakMode = NSLineBreakByTruncatingTail;
  self->_tf.cell.wraps = NO;
  self->_tf.cell.usesSingleLineMode = YES;
  
  self->_tf.alignment = NSTextAlignmentLeft;
  self->_tf.translatesAutoresizingMaskIntoConstraints = NO;
  self->_tf.font      = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
  self->_tf.textColor = [NSColor blackColor];
  
  self->_pi = [self makeProgressIndicator];
  
  if (self->_iv) [self addSubview:self->_iv];
  if (self->_tf) [self addSubview:self->_tf];
  if (self->_pi) [self addSubview:self->_pi];
  
#if 0 // TESTING
  [self->_pi startAnimation:nil];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
    [self->_pi stopAnimation:nil];
  });
#endif
}

static inline NSArray *vfl(NSString *_vfl, NSDictionary *_views) {
  return [NSLayoutConstraint constraintsWithVisualFormat:_vfl
                             options:0 metrics:nil views:_views];
}

- (void)_zzCreateConstraints {
  NSDictionary *nv = self->_iv
    ? @{ @"image": self->_iv, @"title": self->_tf, @"progress": self->_pi }
    : @{ @"title": self->_tf, @"progress": self->_pi };
  
  NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:8];
  
  /* horizontal */
  
  if (self->_iv)
    [constraints addObjectsFromArray:vfl(@"H:|-[image]-[title]-|", nv)];
  else
    [constraints addObjectsFromArray:vfl(@"H:|-10-[title]-|", nv)];
  
  [constraints addObjectsFromArray:vfl(@"H:|[progress]|", nv)];
  
  [_tf setContentHuggingPriority:230
       forOrientation:NSLayoutConstraintOrientationHorizontal];
  
  /* vertical */
  // TODO: bulk activate
  if (self->_iv)
    [constraints addObject:[_iv.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];
  
  [constraints addObject:[_tf.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]];

  [constraints addObjectsFromArray:vfl(@"V:[progress(==3)]|", nv)];
  
  [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark Children

- (NSTextField *)textField {
  return self->_tf;
}

- (NSImageView *)imageView {
  return self->_iv;
}

- (NSProgressIndicator *)spinner {
  return self->_pi;
}


#pragma mark Spinner

- (void)startSpinner {
  if (self->spinnerCount == 0) {
    [self->_pi startAnimation:self];
    //self->_refreshButton.hidden    = YES;
    //self->_tbView.imageView.hidden = YES;
  }
  self->spinnerCount++;
}
- (void)stopSpinner {
  if (self->spinnerCount == 0) return;
  
  self->spinnerCount--;
  if (self->spinnerCount == 0) {
    [self->_pi stopAnimation:self];
    //self->_refreshButton.hidden = NO;
  }
}
- (void)fullstopSpinner {
  self->spinnerCount = 0;
  [self->_pi stopAnimation:self];
}

#pragma mark Title

- (void)setStringValue:(NSString *)_value {
  self->_tf.stringValue = _value;
}
- (NSString *)stringValue {
  return self->_tf.stringValue;
}

@end

