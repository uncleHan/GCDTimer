//
//  GoodTimer.m
//  GCD定时器
//
//  Created by 韩恒 on 2019/12/17.
//  Copyright © 2019 韩恒. All rights reserved.
//

#import "GoodTimer.h"


static NSMutableDictionary *timerDic_;
/*因为创建任务和取消任务都会访问timerDic_
 ,如果是多线程的话,很可能出现问题,
 所以要做加锁解锁操作*/
static dispatch_semaphore_t semaphore_;

@implementation GoodTimer

//initialize会在这个类第一次接受消息的时候调用
+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerDic_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);
    });
}

+ (NSString *)executeTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async{
    
    if (!task || start < 0 || (repeats && interval <= 0)) {
        return nil;
    }
    
    //根据 async 决定是主线程还是子线程
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
    //创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置事件
   dispatch_source_set_timer(
                             timer,
                             dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                             interval * NSEC_PER_SEC,
                             0);
#pragma mark 涉及到字典读取和写入的操作需要加锁,解锁
    //加锁
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    //获取identifier
    NSString *identifier = [NSString stringWithFormat:@"%zd",[timerDic_ count]];
    //把定时器加入到timerDic_
    timerDic_[identifier] = timer;
    //解锁
    dispatch_semaphore_signal(semaphore_);
    //设置回调
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeats) {
            //不重复,就取消定时器
            [self cancelTask:identifier];
        }
       });
    //启动定时器
    dispatch_resume(timer);
    return identifier;
}


+ (NSString *)executeTaskWithTarget:(id)target selector:(SEL)sel start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async{
    return [self executeTask:^{
        if ([target respondsToSelector:sel]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored"-Warc-performSelector-leaks"
            [target performSelector:sel];
            #pragma clang diagnostic pop
        }
    } start:start interval:interval repeats:repeats async:async];
}


//取消任务
+ (void)cancelTask:(NSString *)timerIdentifier{
    if (timerIdentifier.length == 0) {
        return;
    }
    //加锁
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timerDic_[timerIdentifier];
    if (timer) {
        //取消任务
        dispatch_source_cancel(timerDic_[timerIdentifier]);
        //把任务从timerDic_中移除
        [timerDic_ removeObjectForKey:timerIdentifier];
    }
    //解锁
    dispatch_semaphore_signal(semaphore_);
}
@end
