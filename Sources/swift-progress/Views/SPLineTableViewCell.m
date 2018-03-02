//
//  SPLineTableViewCell.m
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

#import "SPLineTableViewCell.h"

@implementation SPLineTableViewCell
{
  NSString *imageName;
  UXImage  *image;
  UXImage  *selectedImage;
}

- (id)initWithFrame:(CGRect)frameRect {
  if ((self = [super initWithFrame:frameRect])) {
    [self _zzCreateSubviews];
    [self _zzCreateConstraints];
  }
  return self;
}

- (id)init {
  return [self initWithFrame:NSZeroRect];
}

- (void)_zzCreateSubviews {
  UXViewFactory *vf = [UXViewFactory defaultViewFactory];

  UXImageView *iv = [self _zzCreateImageView];
  UXLabel     *tf = [vf makeLabel:@"Title"];
  iv.identifier = @"image";
  tf.identifier = @"title";
  
  self->_subtitleView = [vf makeLabel:@"Subtitle"];
  self->_subtitleView.identifier = @"subtitle";
  self->_subtitleView.textColor = [UXColor secondaryLabelColor];
  self->_subtitleView.font =
           [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
  
  [self addSubview:iv];
  [self addSubview:tf];
  [self addSubview:self->_subtitleView];
  
  self.imageView = iv;
  self.textField = tf;
}

- (UXImageView *)_zzCreateImageView {
  NSImageView *iv = [[NSImageView alloc] initWithFrame:NSZeroRect];
  iv.translatesAutoresizingMaskIntoConstraints = NO;
  iv.imageAlignment      = NSImageAlignCenter;
  iv.imageScaling        = NSImageScaleProportionallyDown;
  iv.wantsLayer          = YES;
  iv.layer.masksToBounds = YES;
  iv.layer.cornerRadius  = 8;
  iv.image = [NSImage imageNamed:NSImageNameUserAccounts];
  return iv;
}

static inline NSArray *vfl(NSString *_vfl, NSDictionary *_views) {
  return [NSLayoutConstraint constraintsWithVisualFormat:_vfl
                             options:0 metrics:nil views:_views];
}

- (void)_zzCreateConstraints {
  NSDictionary *views = @{
    @"image":    self.imageView,
    @"title":    self.textField,
    @"subtitle": self.subtitleView
  };
  NSMutableArray *constraints = [NSMutableArray arrayWithCapacity:24];
  [constraints addObject:
     [NSLayoutConstraint constraintWithItem:self.imageView
                         attribute:NSLayoutAttributeHeight
                         relatedBy:NSLayoutRelationEqual
                         toItem:self.imageView
                         attribute:NSLayoutAttributeWidth
                         multiplier:1 constant:0]];
  
  NSArray *vfls = @[
    @"H:|-6-[image]-4-[title]-2-|",
    @"H:|-6-[image]-4-[subtitle]-2-|",
    @"V:|-2-[image]-2-|",
    @"V:|-4-[title][subtitle]-4-|"
  ];
  for (NSString *s in vfls) {
    [constraints addObjectsFromArray:vfl(s, views)];
  }
  [NSLayoutConstraint activateConstraints:constraints];
  
  [self.imageView      setContentCompressionResistancePriority:100
                       forOrientation:NSLayoutConstraintOrientationHorizontal];
  [self.imageView      setContentHuggingPriority:231
                       forOrientation:NSLayoutConstraintOrientationHorizontal];
  [self.textField      setContentHuggingPriority:230
                       forOrientation:NSLayoutConstraintOrientationHorizontal];
  [self->_subtitleView setContentHuggingPriority:230
                       forOrientation:NSLayoutConstraintOrientationHorizontal];
}


#pragma mark Selection

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
  // http://gentlebytes.com/blog/2011/08/30/view-based-table-views-in-lion-part-1-of-2/
  [super setBackgroundStyle:backgroundStyle];
  
  BOOL isSelected = (backgroundStyle == NSBackgroundStyleDark);
  
  self->_subtitleView.textColor = isSelected
                                    ? [NSColor windowBackgroundColor]
                                    : [NSColor controlShadowColor];
  self.imageView.image = isSelected && self->selectedImage != nil
                           ? self->selectedImage : self->image;
}


#pragma mark Accessors

- (void)setTitle:(NSString *)s     { self.textField.stringValue = s;    }
- (NSString *)title                { return self.textField.stringValue; }

- (void)setSubtitle:(NSString *)s  { self->_subtitleView.stringValue = s;    }
- (NSString *)subtitle             { return self->_subtitleView.stringValue; }

- (void)setImage:(UXImage *)_image {
  self->image = _image;
  self.imageView.image = _image;
  
  NSString *s = _image.name;
  if ([s length] > 0) {
    self->selectedImage  =
      [NSImage imageNamed:[s stringByAppendingString:@"Selected"]];
  }
}
- (UXImage *)image {
  return self->image;
}

- (void)setImageName:(NSString *)s {
  self->image          = [NSImage imageNamed:s];
  self->selectedImage  =
          [NSImage imageNamed:[s stringByAppendingString:@"Selected"]];
  
  self.imageView.image = self->image;
}
- (NSString *)imageName {
  return self->image.name;
}

@end /* SPLineTableViewCell */
