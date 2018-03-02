//
//  SPTabViewController.h
//  swift-progress
//
//  Created by Helge Hess on 27.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

@import Cocoa;

@interface SPTabViewController : NSViewController

- (NSTabView *)tabView;

- (void)handleLine:(NSString *)_line error:(BOOL)_flag;

@end
