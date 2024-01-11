//
//  ZLPhotosSelectNavBar.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectNavBar.h"
#import "ZLPhotosSelectConfig.h"

@implementation ZLPhotosSelectNavBar

#pragma mark - LifeCycle
- (void)dealloc {
    if ([ZLPhotosSelectConfig shared].showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】navgition bar object safe release");
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        [self leftButton];
        [self rightButton];
    }
    return self;
}

#pragma mark - Lazy
- (UIButton *)leftButton {
    if (!_leftButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 39.0, 50.0, 34.0)];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithWhite:51 / 255.0 alpha:1.0] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        _leftButton = button;
    }
    return _leftButton;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(70.0 +  15.0, self.frame.size.height - 39.0, self.frame.size.width - 70.0 -  15.0 - 70.0 - 15.0, 34.0)];
        label.text = @"所有照片";
        label.font = [UIFont systemFontOfSize:18.0];
        label.textColor = UIColor.blackColor;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _titleLabel = label;
    }
    return _titleLabel;
}
- (UIButton *)rightButton {
    if (!_rightButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLabel.frame), self.frame.size.height - 35.0, 70.0, 30.0)];
        [button setTitle:@"下一步" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        button.backgroundColor = ZLPhotosSelectConfig.shared.mainColor;
        button.layer.cornerRadius = CGRectGetHeight(button.frame) / 2;
        button.layer.masksToBounds = YES;
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [button addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
        button.hidden = YES;
        [self addSubview:button];
        _rightButton = button;
    }
    return _rightButton;
}

#pragma mark - Action
- (void)leftButtonAction {
    if (self.leftItemAction) {
        self.leftItemAction();
    }
}
- (void)rightButtonAction {
    if (self.rightItemAction) {
        self.rightItemAction();
    }
}

@end
