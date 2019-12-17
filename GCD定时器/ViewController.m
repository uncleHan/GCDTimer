//
//  ViewController.m
//  GCD定时器
//
//  Created by 韩恒 on 2019/12/17.
//  Copyright © 2019 韩恒. All rights reserved.
//

#import "ViewController.h"
#import "GoodTimer.h"

@interface ViewController ()

@property (nonatomic,strong)dispatch_source_t timer ;
@property (nonatomic,strong)NSString *timerId;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
//    self.timerId = [GoodTimer executeTask:^{
//        NSLog(@"封装是否成功");
//    } start:3 interval:-1 repeats:YES async:YES];
    
    self.timerId = [GoodTimer executeTaskWithTarget:self selector:@selector(timerAction) start:2 interval:1 repeats:YES async:YES];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [GoodTimer cancelTask:self.timerId];
}

- (void) timerAction{
    NSLog(@"222 ---%@",[NSThread currentThread]);
}

@end


/***
     
 //    //创建一个定时器
 //    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
 //    //设置事件
 //    dispatch_source_set_timer(
 //                              self.timer,
 //                              dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC),//开始事件,从 3 秒后开始
 //                              1.0 * NSEC_PER_SEC,//没间隔 1 秒
 //                              0
 //                              );
 //    //设置回调
 ////    dispatch_source_set_event_handler(self.timer, ^{
 ////        NSLog(@"定时器事件");
 ////    });
 //
 //    dispatch_source_set_event_handler_f(self.timer, timerAction);
 //
 //    //启动定时器
 //    dispatch_resume(self.timer);
 */
