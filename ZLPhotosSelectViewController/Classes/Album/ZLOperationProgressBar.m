//
//  ZLOperationProgressBar.m
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/8.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLOperationProgressBar.h"
#import "ZLPhotosSelectConfig.h"

@interface ZLOperationProgressBar ()

///前景条
@property (nonatomic,weak) UIView *foreView;

@end

@implementation ZLOperationProgressBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self foreView];
    }
    return self;
}

#pragma mark - Set
- (void)setForeColor:(UIColor *)foreColor {
    _foreColor = foreColor;
    self.foreView.backgroundColor = foreColor;
}
- (void)setProgress:(CGFloat)progress {
    if (_progress == progress) {
        return;
    }
    _progress = progress;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.foreView.frame = CGRectMake(weakSelf.foreView.frame.origin.x, weakSelf.foreView.frame.origin.y, weakSelf.frame.size.width * progress, weakSelf.foreView.frame.size.height);
    } completion:^(BOOL finished) {
        if (weakSelf.foreView.frame.size.width == weakSelf.frame.size.width) {
            [weakSelf removeFromSuperview];
            ZLPhotosSelectConfig.shared.progressBar = nil;
        }
    }];
}

#pragma mark - Lazy
- (UIView *)foreView {
    if (!_foreView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];
        _foreView = view;
    }
    return _foreView;
}

#pragma mark - Action
///展示在指定视图上
+ (void)show:(UIView * _Nullable)superView TopInset:(CGFloat)topInset {
    if (ZLPhotosSelectConfig.shared.progressBar) {
        return;
    }
    ZLOperationProgressBar *progressBar = [[ZLOperationProgressBar alloc] initWithFrame:CGRectMake(0, topInset, UIScreen.mainScreen.bounds.size.width, 2.0)];
    progressBar.backgroundColor = [UIColor colorWithWhite:240 / 255.0 alpha:1.0];
    progressBar.foreColor = ZLPhotosSelectConfig.shared.mainColor;
    progressBar.progress = 0;
    superView = superView ? superView : UIApplication.sharedApplication.delegate.window;
    [superView addSubview:progressBar];
    ZLPhotosSelectConfig.shared.progressBar = progressBar;
}

///关闭
- (void)dismiss {
    [self removeFromSuperview];
    ZLPhotosSelectConfig.shared.progressBar = nil;
}

@end
