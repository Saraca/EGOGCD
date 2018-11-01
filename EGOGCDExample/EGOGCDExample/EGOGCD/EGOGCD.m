//
//  EGOGCD.m
//  NotEatFat
//
//  Created by RLY on 2018/10/29.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import "EGOGCD.h"


@implementation EGODispatchQueue

//MARK: Get a queue
+ (EGODispatchQueue *)mainQueue
{
    static EGODispatchQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [EGODispatchQueue new];
        queue.dispatchQueue = dispatch_get_main_queue();
    });
    return queue;
}

+ (EGODispatchQueue *)globalQueue
{
    static EGODispatchQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [EGODispatchQueue new];
        queue.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    });
    return queue;
}

+ (EGODispatchQueue *)globalQueueHighPriority
{
    static EGODispatchQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [EGODispatchQueue new];
        queue.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    });
    return queue;
}

+ (EGODispatchQueue *)globalQueueLowPriority
{
    static EGODispatchQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [EGODispatchQueue new];
        queue.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    });
    return queue;
}

+ (EGODispatchQueue *)globalQueueBackground
{
    static EGODispatchQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [EGODispatchQueue new];
        queue.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    });
    return queue;
}

- (instancetype)init
{
    return [[EGODispatchQueue alloc] initConcurrentQueueWithLabel:@"com.EGODispatchQueue.concurrent"];
}

- (EGODispatchQueue *)initSerialQueueWithLabel:(NSString *)label
{
    self = [super init];
    if (self) {
        label = label.length ?label :@"com.EGODispatchQueue.serial";
        self.dispatchQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (EGODispatchQueue *)initConcurrentQueueWithLabel:(NSString *)label
{
    self = [super init];
    if (self) {
        label = label.length ?label :@"com.EGODispatchQueue.concurrent";
        self.dispatchQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

//MARK: Execute Method
- (void)execute:(dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_async(self.dispatchQueue, block);
}

- (void)executeSync:(dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_sync(self.dispatchQueue, block);
}

- (void)execute:(dispatch_block_t)block afterDelay:(NSTimeInterval)second
{
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, second * NSEC_PER_SEC), self.dispatchQueue, block);
}

//MARK: lock execute
+ (void)executeInLock:(dispatch_block_t)block
{
    [self executeInLock:block lockSecond:0];
}

+ (void)executeInLock:(dispatch_block_t)block lockSecond:(NSTimeInterval)lockSecond
{
    NSParameterAssert(block);
    static dispatch_semaphore_t semaphore;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        semaphore = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(semaphore, lockSecond <= 0 ?DISPATCH_TIME_FOREVER :dispatch_time(DISPATCH_TIME_NOW, lockSecond * NSEC_PER_SEC));
    block();
    dispatch_semaphore_signal(semaphore);
}

//MARK: execute in a group
- (void)execute:(dispatch_block_t)block inGroup:(EGODispatchGroup *)group
{
    NSParameterAssert(block);
    dispatch_group_async(group.dispatchGroup, self.dispatchQueue, block);
}

- (void)notify:(dispatch_block_t)block inGroup:(EGODispatchGroup *)group
{
    NSParameterAssert(block);
    dispatch_group_notify(group.dispatchGroup, self.dispatchQueue, block);
}

//MARK: execute in a queue
+ (void)executeInMainQueue:(dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_async([EGODispatchQueue mainQueue].dispatchQueue, block);
}

+ (void)executeInGlobalQueue:(dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_async([EGODispatchQueue globalQueue].dispatchQueue, block);
}

+ (void)executeAsync:(dispatch_block_t)block inQueue:(EGODispatchQueue *)queue
{
    NSParameterAssert(block);
    dispatch_async(queue.dispatchQueue, block);
}

+ (void)executeSync:(dispatch_block_t)block inQueue:(EGODispatchQueue *)queue
{
    NSParameterAssert(block);
    dispatch_sync(queue.dispatchQueue, block);
}

+ (void)execute:(dispatch_block_t)block inQueue:(EGODispatchQueue *)queue afterDelay:(NSTimeInterval)second
{
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * second), queue.dispatchQueue, block);
}

//MARK: execute with barrier
/**
 使用的线程池应该是你自己创建的并发线程池，如果你传进来的参数为串行线程池
 或者是系统的并发线程池中的某一个，这个方法就会被当做一个普通的async操作，
 异步障碍任务只会将队列中的任务设置障碍而不会阻碍后面的主线程的代码。
 @param block dispatch_block_t
 */
- (void)executeAsyncWithBarrier:(dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_barrier_async(self.dispatchQueue, block);
}

/**
 会阻塞当前线程
 
 @param block dispatch_block_t
 */
- (void)executeSyncWithBarrier:(dispatch_block_t)block
{
    NSParameterAssert(block);
    dispatch_barrier_sync(self.dispatchQueue, block);
}

//MARK: control
- (void)suspend
{
    dispatch_suspend(self.dispatchQueue);
}

- (void)resume
{
    dispatch_resume(self.dispatchQueue);
}


@end


@implementation EGODispatchGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)enter
{
    dispatch_group_enter(self.dispatchGroup);
}

- (void)leave
{
    dispatch_group_leave(self.dispatchGroup);
}

- (void)wait
{
    dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
}

- (BOOL)wait:(NSTimeInterval)second
{
    return dispatch_group_wait(self.dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, second * NSEC_PER_SEC)) == 0;
}

@end


@implementation EGOSemaphore

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dispatchSemaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (instancetype)initWithSemaphore:(long)value
{
    self = [super init];
    if (self) {
        _dispatchSemaphore = dispatch_semaphore_create(value);
    }
    return self;
}

- (BOOL)signal
{
    return dispatch_semaphore_signal(self.dispatchSemaphore) != 0;
}

- (BOOL)wait
{
    if ([NSThread isMainThread]) {
        EGOLogObj(@"<Warnning>: Can't set a wait semaphore in main thread.")
        return NO;
    }
    return dispatch_semaphore_wait(self.dispatchSemaphore, DISPATCH_TIME_FOREVER) == 0;
}

- (BOOL)wait:(NSTimeInterval)second
{
    if ([NSThread isMainThread]) {
        EGOLogObj(@"<Warnning>: Can't set a wait semaphore in main thread.")
        return NO;
    }
    return dispatch_semaphore_wait(self.dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, second * NSEC_PER_SEC)) == 0;
}

@end


@implementation EGOTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    return self;
}

- (instancetype)initWithQueue:(EGODispatchQueue *)queue
{
    self = [super init];
    if (self) {
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue.dispatchQueue);
    }
    return self;
}

- (void)setEventHandler:(dispatch_block_t)block timeInterval:(NSTimeInterval)interval
{
    NSParameterAssert(block);
    dispatch_source_set_timer(self.timerSource, dispatch_time(DISPATCH_TIME_NOW, 0), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.timerSource, block);
}

- (void)setEventHandler:(dispatch_block_t)block cancelHandler:(dispatch_block_t)cancelHandler timeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay
{
    NSParameterAssert(block);
    dispatch_source_set_timer(self.timerSource, dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.timerSource, block);
    dispatch_source_set_cancel_handler(self.timerSource, cancelHandler);
}

- (void)fire
{
    dispatch_resume(_timerSource);
}

- (void)invalidate
{
    dispatch_source_cancel(_timerSource);
    _timerSource = nil;
}

@end
