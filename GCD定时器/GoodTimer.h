//
//  GoodTimer.h
//  GCD定时器
//
//  Created by 韩恒 on 2019/12/17.
//  Copyright © 2019 韩恒. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodTimer : NSObject

//添加任务,创建定时器后会返回定时器的唯一标识
+ (NSString *)executeTask:(void(^)(void))task
            start:(NSTimeInterval)start
            interval:(NSTimeInterval)interval
            repeats:(BOOL)repeats
            async:(BOOL)async;


//添加任务,采用target sel 的方式
+ (NSString *)executeTaskWithTarget:(id)target
            selector:(SEL)sel
            start:(NSTimeInterval)start
            interval:(NSTimeInterval)interval
            repeats:(BOOL)repeats
            async:(BOOL)async;



//根据唯一标识,停止任务
+ (void)cancelTask:(NSString *)timerIdentifier;
@end

NS_ASSUME_NONNULL_END
