//
//  EGOGCD.m
//  NotEatFat
//
//  Created by RLY on 2018/10/29.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import "EGOGCD.h"
#import "YYDispatchQueuePool.h"
#import <objc/runtime.h>

@implementation EGODispatchQueue (YYDispatchQueuePoolAdditions)


/**
 https://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/
 
 * 简单的工具 YYDispatchQueuePool，为不同优先级创建和 CPU 数量相同的 serial queue，每次从 pool 中获取 queue 时，会轮询返回其中一个 queue。我把 App 内所有异步操作，包括图像解码、对象释放、异步绘制等，都按优先级不同放入了全局的 serial queue 中执行，这样尽量避免了过多线程导致的性能问题

 @return YYDispatchQueuePool
 */
+ (YYDispatchQueuePool *)yy_queuePool
{
    YYDispatchQueuePool *pool = objc_getAssociatedObject(self, &_cmd);
    if (!pool) {
        pool = [YYDispatchQueuePool defaultPoolForQOS:NSQualityOfServiceUserInitiated];
        objc_setAssociatedObject(self, &_cmd, pool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return pool;
}

+ (EGODispatchQueue *)yy_dispatchQueue
{
    static EGODispatchQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [EGODispatchQueue new];
    });
    queue.dispatchQueue = [EGODispatchQueue yy_queuePool].queue;
    return queue;
}

+ (EGODispatchQueue *)yy_dispatchQueueWithQos:(NSQualityOfService)qos
{
    static EGODispatchQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [EGODispatchQueue new];
    });
    queue.dispatchQueue = [YYDispatchQueuePool defaultPoolForQOS:qos].queue;
    return queue;
}

@end
