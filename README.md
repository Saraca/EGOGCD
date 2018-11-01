
# EGOGCD
  ##对GCD常用对象和操作的封装，如dispatch_queue_t、dispatch_group_t、dispatch_barrier_async、dispatch_semaphore_t、GCDTimer。参考了一个GCD demo，并去掉了不常用的方法，加入了自己常用的。另外这个类本来放在一个Pod私有库组件中，由于想借鉴YY的一些经验来优化多线程操作，便引入了YYDispatchQueuePool，如有不正确之处，还请指出，一起学习。
  
 ## 用法

 ```
- (void)testGCDExecuteOrder
{
    [[EGODispatchQueue globalQueueHighPriority] execute:^{
        EGOSemaphore *lock = [[EGOSemaphore alloc] initWithSemaphore:0];
        
        [[EGODispatchQueue globalQueueHighPriority] execute:^{
            EGOLogObj(@"task 1 start")
            [[EGODispatchQueue mainQueue] execute:^{
                sleep(3);
                EGOLogObj(@"task 1 finish")
                [lock signal];
            }];
        }];
        
        [lock wait];
        
        [[EGODispatchQueue globalQueueHighPriority] execute:^{
            EGOLogObj(@"task 2 start")
            [[EGODispatchQueue mainQueue] execute:^{
                sleep(2);
                EGOLogObj(@"task 2 finish")
                [lock signal];
            }];
        }];
        
        [lock wait];
        
        [[EGODispatchQueue globalQueueHighPriority] execute:^{
            EGOLogObj(@"task 3 start")
            [[EGODispatchQueue mainQueue] execute:^{
                EGOLogObj(@"task 3 finish")
                EGOLogObj(@"\n\n\n\n ======================================= \n\n\n\n")
            }];
        }];
    }];
    
}

- (void)testGCDWithDefualtQueue
{
    [[EGODispatchQueue new] execute:^{
        EGOLogObj([NSThread currentThread])
        EGOSemaphore *lock = [[EGOSemaphore alloc] initWithSemaphore:0];
        
        [[EGODispatchQueue globalQueueHighPriority] execute:^{
            EGOLogFmt(@"task 1 start %@", [NSThread currentThread])
            sleep(3);
            [[EGODispatchQueue globalQueueHighPriority] execute:^{
                EGOLogFmt(@"task 1 finish %@", [NSThread currentThread])
                [lock signal];
            }];
        }];
        
        [[EGODispatchQueue globalQueueHighPriority] execute:^{
            EGOLogFmt(@"task 2 start %@", [NSThread currentThread])
            sleep(2);
            [[EGODispatchQueue globalQueueHighPriority] execute:^{
                EGOLogFmt(@"task 2 finish %@", [NSThread currentThread])
                [lock signal];
            }];
        }];
        
        [lock wait];
        [lock wait];
        
        [[EGODispatchQueue globalQueueHighPriority] execute:^{
            EGOLogFmt(@"task 3 start %@", [NSThread currentThread])
            [[EGODispatchQueue mainQueue] execute:^{
                EGOLogObj(@"task 3 finish")
                EGOLogObj(@"\n\n\n\n ======================================= \n\n\n\n")
            }];
        }];
    }];
}

- (void)testGCDWithYYQueue
{
    [[EGODispatchQueue new] execute:^{
        EGOLogObj([NSThread currentThread])
        EGOSemaphore *lock = [[EGOSemaphore alloc] initWithSemaphore:0];
        
        [[EGODispatchQueue yy_dispatchQueue] execute:^{
            EGOLogFmt(@"task 1 start %@", [NSThread currentThread])
            sleep(3);
            [[EGODispatchQueue yy_dispatchQueue] execute:^{
                EGOLogFmt(@"task 1 finish %@", [NSThread currentThread])
                [lock signal];
            }];
        }];
        
        [[EGODispatchQueue yy_dispatchQueue] execute:^{
            EGOLogFmt(@"task 2 start %@", [NSThread currentThread])
            sleep(2);
            [[EGODispatchQueue yy_dispatchQueue] execute:^{
                EGOLogFmt(@"task 2 finish %@", [NSThread currentThread])
                [lock signal];
            }];
        }];
        
        [lock wait];
        [lock wait];
        
        [[EGODispatchQueue yy_dispatchQueue] execute:^{
            EGOLogFmt(@"task 3 start %@", [NSThread currentThread])
            [[EGODispatchQueue mainQueue] execute:^{
                EGOLogObj(@"task 3 finish")
                EGOLogObj(@"\n\n\n\n ======================================= \n\n\n\n")
            }];
        }];
    }];
}
 ```
