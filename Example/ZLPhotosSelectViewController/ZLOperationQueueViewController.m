//
//  ZLOperationQueueViewController.m
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/10.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLOperationQueueViewController.h"
#import <ZLPhotosSelectHeader.h>

@interface ZLOperationQueueViewController ()

///操作事件
@property (nonatomic,weak) UIButton *operationButton;
///操作信息
@property (nonatomic,weak) UILabel *operationMessageLabel;

@end

@implementation ZLOperationQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self operationButton];
}

#pragma mark - Lazy
- (UIButton *)operationButton {
    if (!_operationButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15.0, 40.0, UIScreen.mainScreen.bounds.size.width - 30.0, 45.0)];
        button.backgroundColor = UIColor.cyanColor;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.7].CGColor;
        button.layer.cornerRadius = CGRectGetHeight(button.frame) / 2;
        button.layer.masksToBounds = YES;
        [button setTitle:@"一键测试排队操作" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [button addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _operationButton = button;
    }
    return _operationButton;
}
- (UILabel *)operationMessageLabel {
    if (!_operationMessageLabel) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.operationButton.frame) + 30.0, UIScreen.mainScreen.bounds.size.width - 30.0, 80.0)];
        view.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
        view.layer.cornerRadius = 3.0;
        view.layer.masksToBounds = YES;
        [self.view addSubview:view];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, UIScreen.mainScreen.bounds.size.width - 30.0 - 20.0, 60.0)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor colorWithWhite:51 / 255.0 alpha:1.0];
        [view addSubview:label];
        _operationMessageLabel = label;
    }
    return _operationMessageLabel;
}

#pragma mark - Action
///操作耗时任务
- (void)action {
    [self debugShowTopMessage];
    
    //假设9个任务
    NSInteger count = 9;
    
    //开启进度条
    [ZLOperationProgressBar show:self.view TopInset:10];
    
    __weak typeof(self)weakSelf = self;
    
    //图片根据forIndex进行取出，然后经过一番操作，在发送至后台之后，调用next进行操作下一个图片，当图片操作完成，会调用结果
    [ZLOperationManager timeConsumingTasks:^(NSInteger forIndex, ZLOperationBlock  _Nullable nextTask) {
        
        [weakSelf debugShowWillOperationMessage:forIndex];
        
        //模拟耗时任务
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf debugShowDidOperationMessage:forIndex];
            
            //更新进度条
            ZLPhotosSelectConfig.shared.progressBar.progress = (forIndex + 1) / (count * 1.0);
            
            //执行下一个任务
            nextTask();
        });
    } DependencyCount:count Result:^{
        [weakSelf debugShowDoneMessage];
    }];
}
- (void)debugShowTopMessage {
    self.operationMessageLabel.text = nil;
    NSString *currentString = @"数据准备中\n";
    [self setOperationMessageLabelByAppendingText:currentString];
}
- (void)debugShowWillOperationMessage:(NSInteger)forIndex {
    NSString *currentString = [NSString stringWithFormat:@"索引%ld的任务已开启",forIndex];
    [self setOperationMessageLabelByAppendingText:currentString];
}
- (void)debugShowDidOperationMessage:(NSInteger)forIndex {
    NSString *currentString = [NSString stringWithFormat:@"索引%ld的任务已完成\n",forIndex];
    [self setOperationMessageLabelByAppendingText:currentString];
}
- (void)debugShowDoneMessage {
    NSString *currentString = @"全部完成";
    [self setOperationMessageLabelByAppendingText:currentString];
}
- (void)setOperationMessageLabelByAppendingText:(NSString *)currentString {
    self.operationMessageLabel.text = !self.operationMessageLabel.text ? currentString : [NSString stringWithFormat:@"%@\n%@",self.operationMessageLabel.text,currentString];
    CGFloat height = [self.operationMessageLabel.text boundingRectWithSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 50.0, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size.height;
    self.operationMessageLabel.frame = CGRectMake(self.operationMessageLabel.frame.origin.x, self.operationMessageLabel.frame.origin.y, self.operationMessageLabel.frame.size.width, height);
    self.operationMessageLabel.superview.frame = CGRectMake(self.operationMessageLabel.superview.frame.origin.x, self.operationMessageLabel.superview.frame.origin.y, self.operationMessageLabel.superview.frame.size.width, height + 20.0);
}

@end
