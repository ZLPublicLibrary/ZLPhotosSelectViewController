//
//  ZLPhotosSelectNavBar.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectNavBar : UIView

///左边的按钮（返回键）
@property (nonatomic,weak) UIButton *leftButton;
///标题
@property (nonatomic,weak) UILabel *titleLabel;
///右边的按钮（保存键）
@property (nonatomic,weak) UIButton *rightButton;

///左边按钮的事件
@property (nonatomic,copy) void (^leftItemAction)(void);
///右边按钮的事件
@property (nonatomic,copy) void (^rightItemAction)(void);

@end

NS_ASSUME_NONNULL_END
