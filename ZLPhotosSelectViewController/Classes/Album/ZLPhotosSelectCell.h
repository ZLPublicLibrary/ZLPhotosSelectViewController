//
//  ZLPhotosSelectCell.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotosSelectImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectCell : UICollectionViewCell

///图片
@property (nonatomic,weak) ZLPhotosSelectImageView *imageView;
///蒙版
@property (nonatomic,weak) UIView *hudView;
///标记
@property (nonatomic,weak) UIButton *markButton;

@end

NS_ASSUME_NONNULL_END
