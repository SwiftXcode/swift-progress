//
//  main.m
//  swift-progress
//
//  Created by Helge Hess on 26.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

@import Cocoa;
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    NSApp = [NSApplication sharedApplication];
    id appDelegate = [AppDelegate new];
    NSApp.delegate = appDelegate;
    [NSApp run];
  }
  return 0;
}
