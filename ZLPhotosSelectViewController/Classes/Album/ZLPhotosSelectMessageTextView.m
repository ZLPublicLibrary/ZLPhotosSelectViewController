//
//  ZLPhotosSelectMessageTextView.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/4.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectMessageTextView.h"

@implementation ZLPhotosSelectMessageTextView

/**展示提示信息
 @param message 提示语
 * BanAutoDismiss   禁止自动消失  默认：NO 不禁止 
 */
+ (void)showMessage:(NSString *)message BanAutoDismiss:(BOOL)isBanAuto {
    UIView *view = UIApplication.sharedApplication.delegate.window;
    
    ZLPhotosSelectMessageTextView *unitView = [[ZLPhotosSelectMessageTextView alloc] initWithFrame:view.bounds];
    [view addSubview:unitView];
    
    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - 130.0;
    CGSize size = [message boundingRectWithSize:CGSizeMake(maxWidth,MAXFLOAT) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
    CGFloat width = (size.width > maxWidth ? maxWidth : size.width) + 30.0;
    CGFloat height = size.height + 20.0;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((unitView.frame.size.width - width) / 2.0, (unitView.frame.size.height - height) / 2.0, width, height)];
    [button setTitle:message forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 15.0, 0, 15.0);
    button.layer.cornerRadius = 3.0;
    button.layer.masksToBounds = YES;
    button.backgroundColor = UIColor.blackColor;
    [unitView addSubview:button];
    if (!isBanAuto) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [unitView removeFromSuperview];
        });
    }
}

/**关闭提示
 */
+ (void)dismiss {
    for (ZLPhotosSelectMessageTextView *view in UIApplication.sharedApplication.delegate.window.subviews) {
        if ([view isKindOfClass:[self class]]) {
            [view removeFromSuperview];
        }
    }
}

@end
