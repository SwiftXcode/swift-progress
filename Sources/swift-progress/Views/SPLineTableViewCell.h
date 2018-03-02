//
//  SPLineTableViewCell.h
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

@import Cocoa;

#import "UXViewFactory.h"

@interface SPLineTableViewCell : NSTableCellView

@property (readonly, nonatomic) UXLabel *subtitleView;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic)       UXImage  *image;

@end
