//
//  EGOGCD.h
//  NotEatFat
//
//  Created by RLY on 2018/10/29.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef EGOLogObj
#define EGOLogFmt(fammatStr, ...)       NSLog(@"|%s [line %d]|" fammatStr,__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);
#define EGOLogObj(obj)                  NSLog(@"|%s '%@'|",__PRETTY_FUNCTION__, obj);
#endif

NS_ASSUME_NONNULL_BEGIN

@class EGODispatchGroup, EGOSemaphore;
/// 常用GCD操作
@interface EGODispatchQueue : NSObject

@property (strong, nonatomic) dispatch_queue_t dispatchQueue;

//MARK: Get a queue
+ (EGODispatchQueue *)mainQueue;
+ (EGODispatchQueue *)globalQueue;
+ (EGODispatchQueue *)globalQueueHighPriority;
+ (EGODispatchQueue *)globalQueueLowPriority;
+ (EGODispatchQueue *)globalQueueBackground;
- (EGODispatchQueue *)initSerialQueueWithLabel:(NSString *)label;
- (EGODispatchQueue *)initConcurrentQueueWithLabel:(NSString *)label;

//MARK: Execute Method
- (void)execute:(dispatch_block_t)block;
- (void)execute:(dispatch_block_t)block afterDelay:(NSTimeInterval)second;

// lock execute
+ (void)executeInLock:(dispatch_block_t)block;
+ (void)executeInLock:(dispatch_block_t)block lockSecond:(NSTimeInterval)lockSecond;

// execute in a queue
+ (void)executeInMainQueue:(dispatch_block_t)block;
+ (void)executeInGlobalQueue:(dispatch_block_t)block;
+ (void)executeAsync:(dispatch_block_t)block inQueue:(EGODispatchQueue *)queue;
+ (void)executeSync:(dispatch_block_t)block inQueue:(EGODispatchQueue *)queue;
+ (void)execute:(dispatch_block_t)block inQueue:(EGODispatchQueue *)queue afterDelay:(NSTimeInterval)second;

// execute in a group
- (void)execute:(dispatch_block_t)block inGroup:(EGODispatchGroup *)group;
- (void)notify:(dispatch_block_t)block inGroup:(EGODispatchGroup *)group;

// execute with barrier
- (void)executeAsyncWithBarrier:(dispatch_block_t)block;
- (void)executeSyncWithBarrier:(dispatch_block_t)block;

// control
- (void)suspend;
- (void)resume;

@end

/// Dispatch Group
@interface EGODispatchGroup : NSObject

@property (strong, nonatomic, readonly) dispatch_group_t dispatchGroup;

- (instancetype)init;
- (void)enter;
- (void)leave;
- (void)wait;
- (BOOL)wait:(NSTimeInterval)delta;

@end


/// 信号量
@interface EGOSemaphore : NSObject

@property (strong, readonly, nonatomic) dispatch_semaphore_t dispatchSemaphore;

- (instancetype)init;
- (instancetype)initWithSemaphore:(long)value;
- (BOOL)signal;
- (BOOL)wait;
- (BOOL)wait:(NSTimeInterval)delta;

@end


/// GCD 定时器
@interface EGOTimer : NSObject

@property (strong, readonly, nonatomic) dispatch_source_t timerSource;

- (instancetype)init;
- (instancetype)initWithQueue:(EGODispatchQueue *)queue;

- (void)setEventHandler:(dispatch_block_t)block timeInterval:(NSTimeInterval)interval;
- (void)setEventHandler:(dispatch_block_t)block cancelHandler:(dispatch_block_t)cancelHandler timeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay;

- (void)fire;
- (void)invalidate;

@end


NS_ASSUME_NONNULL_END
