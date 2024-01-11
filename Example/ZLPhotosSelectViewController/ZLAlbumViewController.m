//
//  ZLAlbumViewController.m
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/10.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLAlbumViewController.h"
#import <ZLPhotosSelectHeader.h>

@interface ZLAlbumViewController ()

///图片组
@property (nonatomic,weak) UIImageView *imageBox;
///选择图片
@property (nonatomic,weak) UIButton *actionButton;
///当前选中的图片数据
@property (nonatomic,strong) NSArray<ZLPhotosSelectUnitModel *> *images;

@end

@implementation ZLAlbumViewController

- (void)dealloc {
    //在一个上传周期完全结束后，释放因选择图片产生的沙盒数据。
    [ZLPhotosSelectConfig.shared.sandboxManager removeAllSandboxCachePhotosWithOriginal:(ZLPhotosTypeAll)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    //配置项一定要写在最前，避免出现问题
    ZLPhotosSelectConfig.shared.showDebugLog = YES;
    ZLPhotosSelectConfig.shared.maxCount = 9;
    ZLPhotosSelectConfig.shared.mainColor = UIColor.orangeColor;
    
    [self actionButton];
}

#pragma mark - Lazy
- (UIImageView *)imageBox {
    if (!_imageBox) {
        CGFloat width = UIScreen.mainScreen.bounds.size.width - 30.0;
        CGFloat y = 40.0;
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, y, width, width)];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.layer.cornerRadius = 2.0;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];

        for (NSInteger index = 0; index < 9; index++) {
            CGFloat size = (UIScreen.mainScreen.bounds.size.width - 30.0 - 20.0 - 20.0) / 3;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0 + (size + 10.0) * (index % 3), 10.0 + (size + 10.0) * (index / 3), size, size)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.cornerRadius = 3.0;
            imageView.layer.masksToBounds = YES;
            imageView.layer.borderColor = [UIColor colorWithRed:248.0 / 255.0 green:248.0 / 255.0 blue:248.0 / 255.0 alpha:1.0].CGColor;
            imageView.layer.borderWidth = 1.0;
            imageView.userInteractionEnabled = YES;
            imageView.hidden = YES;
            [view addSubview:imageView];
        }

        [self.view addSubview:view];
        _imageBox = view;
    }
    return _imageBox;
}
- (UIButton *)actionButton {
    if (!_actionButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.imageBox.frame) + 30.0, UIScreen.mainScreen.bounds.size.width - 30.0, 45.0)];
        button.backgroundColor = UIColor.cyanColor;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.7].CGColor;
        button.layer.cornerRadius = CGRectGetHeight(button.frame) / 2;
        button.layer.masksToBounds = YES;
        [button setTitle:@"去相册选择图片" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [button addTarget:self action:@selector(photosSelectAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _actionButton = button;
    }
    return _actionButton;
}

#pragma mark - Action
- (void)photosSelectAction {
    self.imageBox.image = nil;

    ZLPhotosSelectViewController *photosSelectVc = [ZLPhotosSelectViewController new];
    photosSelectVc.modalPresentationStyle = NO;
    [self presentViewController:photosSelectVc animated:YES completion:nil];

    //记忆上次选中的图片
    photosSelectVc.lastSelectedPhotos = self.images;

    //实现事件
    __weak typeof(self)weakSelf = self;
    __weak typeof(photosSelectVc)weakVc = photosSelectVc;
    photosSelectVc.leftItemAction = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };

    photosSelectVc.didSelectedPhotos = ^(NSArray<ZLPhotosSelectUnitModel *> * _Nonnull images) {
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithContentsOfFile:images.firstObject.filePath], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        for (NSInteger index = 0; index < weakSelf.imageBox.subviews.count; index++) {
            UIImageView *imageView = weakSelf.imageBox.subviews[index];
            imageView.hidden = YES;
            if (index < images.count) {
                ZLPhotosSelectUnitModel *unitModel = images[index];
                imageView.hidden = NO;
                imageView.image = [UIImage imageWithContentsOfFile:unitModel.filePath];
            }
        }
        weakSelf.images = images;
        if (weakVc.leftItemAction) {
            weakVc.leftItemAction();
        }
    };
}

///保存图片后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

@end
