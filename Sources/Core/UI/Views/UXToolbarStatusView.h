//
//  UXToolbarStatusView.h
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

@import Cocoa;

@interface UXToolbarStatusView : NSView

- (NSTextField         *)textField;
- (NSProgressIndicator *)spinner;
- (NSImageView         *)imageView;

#pragma mark Spinner

- (void)startSpinner;
- (void)stopSpinner;
- (void)fullstopSpinner; // reset retain count

#pragma mark Title

- (void)setStringValue:(NSString *)_value;
- (NSString *)stringValue;

@end
