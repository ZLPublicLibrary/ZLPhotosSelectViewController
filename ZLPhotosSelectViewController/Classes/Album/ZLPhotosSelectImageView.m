//
//  ZLPhotosSelectImageView.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectImageView.h"
#import "ZLPhotosSelectConfig.h"
#import "UIImage+ZLGIF.h"

@implementation ZLPhotosSelectImageView

#pragma mark - LifeCycle
- (void)dealloc {
    if ([ZLPhotosSelectConfig shared].showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】image view object safe release");
    }
    self.image = nil;
}

#pragma mark - Action

///根据图片模型加载图片
- (void)setImageWithUnitModel:(ZLPhotosSelectUnitModel *)unitModel {
    self.image = nil;
    
    unitModel.isGif
    //加载动图
    ? [self setGifImageWithUnitModel:unitModel]
    //加载普通图片
    : [self setNormalImageWithUnitModel:unitModel];
}

///根据模型加载常规图片
- (void)setNormalImageWithUnitModel:(ZLPhotosSelectUnitModel *)unitModel {
    
    //已经加载，根据文件路径进行加载
    if (unitModel.filePath) {
        self.image = [UIImage imageWithContentsOfFile:unitModel.filePath];
        return;
    }
    
    //未加载，但是之前写入过沙盒，然后根据文件路径加载（缓存还在的情况下）
    NSString *imgPath = [ZLPhotosSelectConfig.shared.sandboxManager loadSandboxFilePathWithIdentifier:unitModel.asset.localIdentifier Original:ZLPhotosTypeThumbnail SuffixType:ZLPhotosSuffixTypeJpeg];
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:imgPath];
    if (isExists) {
        unitModel.filePath = imgPath;
        self.image = [UIImage imageWithContentsOfFile:imgPath];
        return;
    }
    
    //从未加载，根据图片信息加载图片，并写入沙盒、同步给模型引用
    __weak typeof(self)weakSelf = self;
    [unitModel getPhotosWithOriginal:NO Results:^(UIImage * _Nullable result) {
        if (!result) {
            return;
        }
        weakSelf.image = result;
        [ZLPhotosSelectConfig.shared.sandboxManager writePhotosInSandboxWithIdentifier:unitModel.asset.localIdentifier Image:result Original:ZLPhotosTypeThumbnail SuffixType:ZLPhotosSuffixTypeJpeg Results:^(NSString * _Nonnull imgPath) {
            unitModel.filePath = imgPath;
        }];
    }];
}

///根据模型加载动图
- (void)setGifImageWithUnitModel:(ZLPhotosSelectUnitModel *)unitModel {
    
    //已经加载，根据文件路径进行加载
    if (unitModel.filePath) {
        self.image = [UIImage animatedGIFWithData:[NSData dataWithContentsOfFile:unitModel.filePath]];
        return;
    }
    
    //未加载，但是之前写入过沙盒，然后根据文件路径加载（缓存还在的情况下）
    NSString *imgPath = [ZLPhotosSelectConfig.shared.sandboxManager loadSandboxFilePathWithIdentifier:unitModel.asset.localIdentifier Original:ZLPhotosTypeThumbnail SuffixType:ZLPhotosSuffixTypeGif];
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:imgPath];
    if (isExists) {
        unitModel.filePath = imgPath;
        self.image = [UIImage animatedGIFWithData:[NSData dataWithContentsOfFile:imgPath]];
        return;
    }
    
    //从未加载，根据图片信息加载图片，并写入沙盒、同步给模型引用
    __weak typeof(self)weakSelf = self;
    [unitModel getGifPhotosWithOriginal:NO Results:^(NSData * _Nullable result) {
        if (!result) {
            return;
        }
        weakSelf.image = [UIImage animatedGIFWithData:result];;
        [ZLPhotosSelectConfig.shared.sandboxManager writePhotosInSandboxWithIdentifier:unitModel.asset.localIdentifier Image:result Original:ZLPhotosTypeThumbnail SuffixType:ZLPhotosSuffixTypeGif Results:^(NSString * _Nonnull imgPath) {
            unitModel.filePath = imgPath;
        }];
    }];
}

@end
