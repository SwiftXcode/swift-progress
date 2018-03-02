//
//  SPLineItem.h
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Fetching git@github.com:helje5/ApacheExpressAdmin.git
 Cloning git@github.com:helje5/ApacheExpressAdmin.git
 Resolving git@github.com:helje5/ApacheExpressAdmin.git at 0.3.6
 Updating https://github.com/AlwaysRightInstitute/WebPackMiniS.git
 Compile Swift Module 'mustache' (6 sources)
 Compile Swift Module 'Freddy' (10 sources)
*/

typedef NS_ENUM(NSInteger, SPLineItemType) {
  SPLineItemTypeCompile,
  SPLineItemTypeFetching,
  SPLineItemTypeCloning,
  SPLineItemTypeResolving,
  SPLineItemTypeUpdating
};

@interface SPLineItem : NSObject
{
@public // risky, highly risky
  SPLineItemType itemType;
  NSString       *line;
  NSString       *module;     // ApacheExpressAdmin
  NSString       *url;        // git@github.com:helje5/ApacheExpressAdmin.git
  NSInteger      sourceCount; // "(6 sources)"
  NSString       *revision;   // "at 0.3.6" => 0.3.6
}

- (instancetype)initWithString:(NSString *)_s;

@end
