//
//  EGOGCD.h
//  NotEatFat
//
//  Created by RLY on 2018/10/29.
//  Copyright © 2018年 RLY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOGCD.h"

NS_ASSUME_NONNULL_BEGIN

@interface EGODispatchQueue (YYDispatchQueuePoolAdditions)

+ (EGODispatchQueue *)yy_dispatchQueue;
+ (EGODispatchQueue *)yy_dispatchQueueWithQos:(NSQualityOfService)qos;

@end

NS_ASSUME_NONNULL_END
