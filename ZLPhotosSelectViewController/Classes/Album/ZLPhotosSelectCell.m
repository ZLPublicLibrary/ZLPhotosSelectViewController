//
//  ZLPhotosSelectCell.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectCell.h"
#import "ZLPhotosSelectConfig.h"

@implementation ZLPhotosSelectCell

#pragma mark - LifeCycle
- (void)dealloc {
    if ([ZLPhotosSelectConfig shared].showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】cell object safe release");
    }
}

#pragma mark - Lazy
- (ZLPhotosSelectImageView *)imageView {
    if (!_imageView) {
        CGFloat size = (UIScreen.mainScreen.bounds.size.width - 25.0) / 4;
        ZLPhotosSelectImageView *imageView = [[ZLPhotosSelectImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = 3.0;
        imageView.layer.masksToBounds = YES;
        imageView.layer.borderColor = [UIColor colorWithRed:248.0 / 255.0 green:248.0 / 255.0 blue:248.0 / 255.0 alpha:1.0].CGColor;
        imageView.layer.borderWidth = 1.0;
        imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}
- (UIView *)hudView {
    if (!_hudView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
        view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        view.hidden = YES;
        view.layer.cornerRadius = 3.0;
        view.layer.masksToBounds = YES;
        view.userInteractionEnabled = NO;
        [self.contentView addSubview:view];
        _hudView = view;
    }
    return _hudView;
}
- (UIButton *)markButton {
    if (!_markButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.imageView.frame) - 25.0, 5.0, 20.0, 20.0)];
        button.layer.cornerRadius = CGRectGetHeight(button.frame) / 2;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 0.5;
        button.userInteractionEnabled = NO;
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self.contentView addSubview:button];
        _markButton = button;
    }
    return _markButton;
}

@end
