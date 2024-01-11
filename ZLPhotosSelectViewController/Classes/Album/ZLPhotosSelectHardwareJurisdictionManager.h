//
//  ZLPhotosSelectHardwareJurisdictionManager.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/4.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

///权限权限类型
typedef NS_ENUM (NSInteger , ZLPhotosSelectHardwareJurisdictionState){
    ///权限都已开启
    ZLPhotosSelectHardwareJurisdictionStateNormal = 0,
    ///权限未全部开启
    ZLPhotosSelectHardwareJurisdictionStateImproper,
    ///未识别到摄像头信息
    ZLPhotosSelectHardwareJurisdictionStateNullCamera,
};

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectHardwareJurisdictionManager : UIView

///查询权限  yes:权限没问题  no:需要进行权限认证
+ (void)queryWithResults:(void(^)(ZLPhotosSelectHardwareJurisdictionState state))results;
///展示权限面板
+ (void)showOnView:(UIView *)superView Results:(void(^)(void))results Dismiss:(void(^)(void))dismissAction;

@end

NS_ASSUME_NONNULL_END
