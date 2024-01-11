//
//  ZLPhotosSelectConfig.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectConfig.h"

@interface ZLPhotosSelectConfig ()

@end

@implementation ZLPhotosSelectConfig

+ (instancetype)shared {
    static ZLPhotosSelectConfig *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
        [manager defaultConfig];
    });
    return manager;
}

#pragma mark - Lazy
- (ZLPhotosSelectSandboxManager *)sandboxManager {
    if (!_sandboxManager) {
        _sandboxManager = [ZLPhotosSelectSandboxManager new];
    }
    return _sandboxManager;
}

#pragma mark - Set
- (void)setShowDebugLog:(BOOL)showDebugLog {
    _showDebugLog = showDebugLog;
    if (showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】sandbox manager start to work");
    }
}

#pragma mark - Action
- (void)defaultConfig {
    self.maxCount = 1;
    self.mainColor = UIColor.blueColor;
    self.thumbnailMaxPoint = 90.0;
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [currentBundle.resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"ZLPhotosSelectViewController.bundle/拍照上传@%dx.png", (int)UIScreen.mainScreen.scale]];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    self.cameraMarkIcon = image;
}

@end
