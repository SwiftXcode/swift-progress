//
//  CommandLineTask.h
//  swift-progress
//
//  Created by Helge Hess on 27.02.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

@import Foundation;

@class CommandLineTask;

@protocol CommandLineTaskDelegate < NSObject >
@optional

- (void)task:(CommandLineTask * _Nonnull)_task
        terminatedWithStatus:(int)_status;

- (void)task:(CommandLineTask * _Nonnull)_task
        receivedLineOnStdOut:(NSString * _Nonnull)_line;
- (void)task:(CommandLineTask * _Nonnull)_task
        receivedLineOnStdErr:(NSString * _Nonnull)_line;

@end

@interface CommandLineTask : NSObject

@property (nullable, weak) id <CommandLineTaskDelegate> delegate;
@property (nullable, nonatomic, copy) NSString          *cwd;
@property (nonatomic) BOOL                              passThrough;

- (instancetype)initWithTool:(NSString *)_tool
                arguments:(NSArray<NSString *> *)_args;
- (void)run;

- (dispatch_queue_t)exitQueue;

@end
