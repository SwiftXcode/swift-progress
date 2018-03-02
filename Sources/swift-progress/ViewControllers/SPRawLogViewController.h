//
//  SPRawLogViewController.h
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

@import Cocoa;

@interface SPRawLogViewController : NSViewController
- (void)handleLine:(NSString *)_line error:(BOOL)_flag;
@end
