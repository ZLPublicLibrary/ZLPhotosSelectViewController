//
//  ZLOperationProgressBar.h
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/8.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLOperationProgressBar : UIView

///前景条
@property (nonatomic,strong) UIColor *foreColor;
///最大值 1.0   最小值   0
@property (nonatomic,unsafe_unretained) CGFloat progress;

///展示在指定视图上
+ (void)show:(UIView * _Nullable)superView TopInset:(CGFloat)topInset;

///关闭
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
