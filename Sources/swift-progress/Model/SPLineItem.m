//
//  SPLineItem.m
//  swift-progress
//
//  Created by Helge Hess on 01.03.18.
//  Copyright © 2018 ZeeZide. All rights reserved.
//

#import "SPLineItem.h"

@implementation SPLineItem

- (instancetype)initWithString:(NSString *)s {
  if ([s length] == 0) return nil;
  
  if ((self = [super init]) != nil) {
    self->line = [s copy];
    s = self->line; // use the copy
    
    // Nah, this is not for being nice. Doesn't belong here ;-)
    if ([s hasPrefix:@"Compile "])        itemType = SPLineItemTypeCompile;
    else if ([s hasPrefix:@"Fetching "])  itemType = SPLineItemTypeFetching;
    else if ([s hasPrefix:@"Cloning "])   itemType = SPLineItemTypeCloning;
    else if ([s hasPrefix:@"Resolving "]) itemType = SPLineItemTypeResolving;
    else if ([s hasPrefix:@"Updating "])  itemType = SPLineItemTypeUpdating;
    else return nil;
    
    // parse compile
    if (itemType == SPLineItemTypeCompile) {
      // Compile Swift Module 'mustache' (6 sources)
      NSRange startQuoteRange = [s rangeOfString:@"'"];
      if (startQuoteRange.location == NSNotFound) {
        if ([s hasPrefix:@"Compile Swift Module "])
          module = [s substringFromIndex:21];
        else
          module = [s copy];
      }
      else {
        NSRange endQuoteRange;
        NSUInteger from = startQuoteRange.location + startQuoteRange.length;
        
        endQuoteRange = [s rangeOfString:@"'" options:0
                           range:NSMakeRange(from, s.length - from)];
        if (endQuoteRange.location == NSNotFound)
          module = [s substringFromIndex:from];
        else {
          module =
            [s substringWithRange:NSMakeRange(from,
                                              endQuoteRange.location - from)];
        }
      }
      
      NSRange sourceEndRange = [s rangeOfString:@" sources)"];
      if (sourceEndRange.location != NSNotFound) {
        NSRange sourceStartRange;
        sourceStartRange = [s rangeOfString:@"(" options:NSBackwardsSearch
                              range:NSMakeRange(0, sourceEndRange.location)];
        if (sourceStartRange.location != NSNotFound) {
          NSUInteger from = sourceStartRange.location + sourceStartRange.length;
          NSString *numstr =
            [s substringWithRange:NSMakeRange(from,
                                              sourceEndRange.location - from)];
          
          long v = strtol([numstr UTF8String], NULL, 10);
          if (v > 0) {
            sourceCount = v;
          }
        }
      }
    }
    else {
    /*
      git@github.com:helje5/ApacheExpressAdmin.git
      git@github.com:helje5/ApacheExpressAdmin.git at 0.3.6
      https://github.com/AlwaysRightInstitute/WebPackMiniS.git
     */
      NSRange atRange = [s rangeOfString:@" at "];
      NSString *base = s;
      if (atRange.location != NSNotFound) {
        NSString *at1 =
          [s substringFromIndex:atRange.location + atRange.length];
        NSRange wsRange = [at1 rangeOfCharacterFromSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (wsRange.location != NSNotFound)
          revision = [at1 substringToIndex:wsRange.location];
        else
          revision = at1;
        
        base = [s substringToIndex:atRange.location];
      }

      NSRange prefixRange = [base rangeOfCharacterFromSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if (prefixRange.location != NSNotFound) {
        base = [base substringFromIndex:
                       prefixRange.location + prefixRange.length];
      }

      url = base;
      
      module = [url lastPathComponent];
      if ([module length] == 0)
        module = url;
      else if ([module hasSuffix:@".git"])
        module = [module stringByDeletingPathExtension];
    }
  }
  return self;
}

- (instancetype)init {
  return [self initWithString:nil];
}

@end
