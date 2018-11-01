//
//  ViewController.m
//  EGOGCDExample
//
//  Created by RLY on 2018/11/1.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import "ViewController.h"
#import "EGOGCD/EGOGCD.h"
#import "EGOGCD/EGOGCD+YYAdditions.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 1、 task顺序执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self testGCDExecuteOrder];
    });
    //[self testGCDExecuteOrder];
    
    
    // 2、 多个task先执行完后再执行后续task
    //[self testGCDWithDefualtQueue];
    [self testGCDWithYYQueue];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self testGCDWithYYQueue];
//    });
}

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




@end
