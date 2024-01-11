//
//  ZLPhotosSelectHardwareJurisdictionManager.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/4.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

///权限权限类型
typedef NS_ENUM (NSInteger , ZLPhotosSelectJurisdictionOpenState){
    ///权限已开启
    ZLPhotosSelectJurisdictionOpenStateNormal = 0,
    ///权限未开启
    ZLPhotosSelectJurisdictionOpenStateRefuseOpen,
    ///权限未进行权限访问
    ZLPhotosSelectJurisdictionOpenStateNull,
};

#import "ZLPhotosSelectHardwareJurisdictionManager.h"
#import <Photos/Photos.h>
#import "ZLPhotosSelectConfig.h"

@interface ZLPhotosSelectHardwareJurisdictionManager ()

///权限打开的个数
@property (nonatomic,unsafe_unretained) NSInteger normalCount;
///权限已经全部打开，进行下一步操作
@property (nonatomic,copy) void (^results)(void);
///消失事件
@property (nonatomic,copy) void (^dismissAction)(void);

@end

@implementation ZLPhotosSelectHardwareJurisdictionManager

///查询权限  yes:权限没问题  no:需要进行权限认证
+ (void)queryWithResults:(void(^)(ZLPhotosSelectHardwareJurisdictionState state))results {
    if (TARGET_IPHONE_SIMULATOR != 1 || TARGET_OS_IPHONE != 1) {
        //真机时，判断是否可以打开照相机
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            results(ZLPhotosSelectHardwareJurisdictionStateNullCamera);
            return;
        }
    }
    [self detailedQueryWithResults:^(BOOL isOk) {
        results(isOk ? ZLPhotosSelectHardwareJurisdictionStateNormal : ZLPhotosSelectHardwareJurisdictionStateImproper);
    }];
}

///详细查询权限
+ (void)detailedQueryWithResults:(void(^)(BOOL isOk))results {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //查询相机
        [self queryCamera:^(ZLPhotosSelectJurisdictionOpenState state) {
            if (state != ZLPhotosSelectJurisdictionOpenStateNormal) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (results) {
                        results(NO);
                    }
                });
                return ;
            }
            //查询录音
            [self queryAudio:^(ZLPhotosSelectJurisdictionOpenState state) {
                if (state != ZLPhotosSelectJurisdictionOpenStateNormal) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (results) {
                            results(NO);
                        }
                    });
                    return ;
                }
                //查询相册
                [self queryPhotoLibrary:^(ZLPhotosSelectJurisdictionOpenState state) {
                    if (state != ZLPhotosSelectJurisdictionOpenStateNormal) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (results) {
                                results(NO);
                            }
                        });
                        return ;
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (results) {
                            results(YES);
                        }
                    });
                } ShowAlert:NO];
            } ShowAlert:NO];
        } ShowAlert:NO];
    });
}

//相册权限识别
+ (void)queryPhotoLibrary:(void(^)(ZLPhotosSelectJurisdictionOpenState state))results ShowAlert:(BOOL)show {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){//用户之前已经授权
        results(ZLPhotosSelectJurisdictionOpenStateNormal);
    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied){//用户之前已经拒绝授权
        results(ZLPhotosSelectJurisdictionOpenStateRefuseOpen);
        if (!show) {
            return;
        }
        [self showJurisdictionTitle:@"无照片操作权限，请将照片权限更改为[读取和写入]"];
    }else{//弹窗授权时监听
        results(ZLPhotosSelectJurisdictionOpenStateNull);
        if (!show) {
            return;
        }
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized){//允许
                    results(ZLPhotosSelectJurisdictionOpenStateNormal);
                }else{//拒绝
                    results(ZLPhotosSelectJurisdictionOpenStateRefuseOpen);
                }
            });
        }];
    }
}

//音频权限识别
+ (void)queryAudio:(void(^)(ZLPhotosSelectJurisdictionOpenState state))results ShowAlert:(BOOL)show {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusAuthorized){//用户之前已经授权
        results(ZLPhotosSelectJurisdictionOpenStateNormal);
    }else if(status == AVAuthorizationStatusRestricted
             || status == AVAuthorizationStatusDenied){//用户之前已经拒绝授权
        results(ZLPhotosSelectJurisdictionOpenStateRefuseOpen);
        if (!show) {
            return;
        }
        [self showJurisdictionTitle:@"无录音权限，请开启录音权限"];
    }else{//弹窗授权时监听
        results(ZLPhotosSelectJurisdictionOpenStateNull);
        if (!show) {
            return;
        }
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {//同意
                        results(ZLPhotosSelectJurisdictionOpenStateNormal);
                    }else {//拒绝
                        results(ZLPhotosSelectJurisdictionOpenStateRefuseOpen);
                    }
                });
            }];
        }
    }
}

//相机权限识别
+ (void)queryCamera:(void(^)(ZLPhotosSelectJurisdictionOpenState state))results ShowAlert:(BOOL)show {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized){//用户之前已经授权
        results(ZLPhotosSelectJurisdictionOpenStateNormal);
    }else if(status == AVAuthorizationStatusRestricted
             || status == AVAuthorizationStatusDenied){//用户之前已经拒绝授权
        results(ZLPhotosSelectJurisdictionOpenStateRefuseOpen);
        if (!show) {
            return;
        }
        [self showJurisdictionTitle:@"无相机权限，请开启相机权限"];
    }else{//弹窗授权时监听
        results(ZLPhotosSelectJurisdictionOpenStateNull);
        if (!show) {
            return;
        }
        //获取访问相机权限时，弹窗的点击事件获取
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {//同意
                    results(ZLPhotosSelectJurisdictionOpenStateNormal);
                }else {//拒绝
                    results(ZLPhotosSelectJurisdictionOpenStateRefuseOpen);
                }
            });
        }];
    }
}

+ (void)showJurisdictionTitle:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        [defaultAction setValue:[UIColor colorWithWhite:99 / 255.0 alpha:1.0] forKey:@"titleTextColor"];
        [alert addAction:defaultAction];
        defaultAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [alert addAction:defaultAction];
        UIViewController *topVc = [self topViewController];
        [topVc presentViewController:alert animated:YES completion:nil];
    });
}

+ (UIViewController *)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

///展示权限
+ (void)showOnView:(UIView *)superView Results:(void(^)(void))results Dismiss:(void(^)(void))dismissAction {
    ZLPhotosSelectHardwareJurisdictionManager *view = [[self alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0];
    view.results = results;
    view.dismissAction = dismissAction;
    
    UIView *unitView = [[UIView alloc] initWithFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width, 400.0)];
    unitView.backgroundColor = UIColor.whiteColor;
    unitView.layer.cornerRadius = 6.0;
    unitView.layer.masksToBounds = YES;
    [view addSubview:unitView];
    
    //子控件
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 20.0, CGRectGetWidth(unitView.frame) - 30.0, 30.0)];
    titleLabel.font = [UIFont boldSystemFontOfSize:25.0];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    titleLabel.text = app_Name;
    titleLabel.textColor = UIColor.blackColor;
    [unitView addSubview:titleLabel];
    
    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, CGRectGetMaxY(titleLabel.frame) + 10.0, CGRectGetWidth(unitView.frame) - 30.0, 20.0)];
    remarkLabel.font = [UIFont systemFontOfSize:14.0];
    remarkLabel.text = ZLPhotosSelectConfig.shared.auth_alert_remaks ? ZLPhotosSelectConfig.shared.auth_alert_remaks : @"开启以下权限，记录和分享您的心得、创作";
    remarkLabel.textColor = UIColor.lightGrayColor;
    [unitView addSubview:remarkLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(unitView.frame) - 50.0, 17.0, 40.0, 40.0)];
    [cancelButton setImage:[UIImage imageNamed:@"关闭发布"] forState:UIControlStateNormal];
    [cancelButton addTarget:view action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [unitView addSubview:cancelButton];
    
    UIView *optionsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(remarkLabel.frame) + 30.0, CGRectGetWidth(unitView.frame), 130.0)];
    optionsView.tag = 86;
    [unitView addSubview:optionsView];
    
    for (NSInteger index = 0; index < 3; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(25.0, 50.0 * index, CGRectGetWidth(optionsView.frame) - 50.0, 30.0)];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.enabled = NO;
        [button addTarget:view action:@selector(itemsAction:) forControlEvents:UIControlEventTouchUpInside];
        [optionsView addSubview:button];
    }
    
    UIButton *allOpenButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY(optionsView.frame) + 40.0, CGRectGetWidth(unitView.frame) - 40.0, 45.0)];
    allOpenButton.layer.cornerRadius = CGRectGetHeight(allOpenButton.frame) / 2;
    allOpenButton.layer.masksToBounds = YES;
    allOpenButton.backgroundColor = ZLPhotosSelectConfig.shared.mainColor;
    [allOpenButton setTitle:@"一键开启" forState:UIControlStateNormal];
    [allOpenButton addTarget:view action:@selector(openAllJurisdictionAction) forControlEvents:UIControlEventTouchUpInside];
    [unitView addSubview:allOpenButton];
    
    __weak typeof(view)weakSelf = view;
    __weak typeof(unitView)weakView = unitView;
    __weak typeof(optionsView)weakOptionsView = optionsView;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //查询事件
        [ZLPhotosSelectHardwareJurisdictionManager queryCamera:^(ZLPhotosSelectJurisdictionOpenState state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *sender = weakOptionsView.subviews.firstObject;
                sender.enabled = YES;
                [weakSelf setMessageWithSender:sender state:state Key:@"相机"];
            });
        } ShowAlert:NO];
        [ZLPhotosSelectHardwareJurisdictionManager queryAudio:^(ZLPhotosSelectJurisdictionOpenState state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *sender = weakOptionsView.subviews[1];
                sender.enabled = YES;
                [weakSelf setMessageWithSender:sender state:state Key:@"录音"];
            });
        } ShowAlert:NO];
        [ZLPhotosSelectHardwareJurisdictionManager queryPhotoLibrary:^(ZLPhotosSelectJurisdictionOpenState state) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIButton *sender = weakOptionsView.subviews.lastObject;
                sender.enabled = YES;
                [weakSelf setMessageWithSender:sender state:state Key:@"相册"];
            });
        } ShowAlert:NO];
    });
        
    [UIView animateWithDuration:0.25 animations:^{
        weakView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - 400.0 + 6.0, UIScreen.mainScreen.bounds.size.width, 400.0);
    } completion:^(BOOL finished) {
        view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
    }];
    
    [superView addSubview:view];
}

- (void)dismiss {
    if (self.dismissAction) {
        self.dismissAction();
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.subviews.firstObject.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.width, 400.0);
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (void)openAllJurisdictionAction {
    __weak typeof(self)weakSelf = self;
    self.normalCount = 0;
    [ZLPhotosSelectHardwareJurisdictionManager queryCamera:^(ZLPhotosSelectJurisdictionOpenState state) {
        UIView *optionsView = [weakSelf viewWithTag:86];
        UIButton *sender = optionsView.subviews.firstObject;
        [weakSelf setMessageWithSender:sender state:state Key:@"相机"];
        [weakSelf gotoNextWithState:state];
    } ShowAlert:YES];
    [ZLPhotosSelectHardwareJurisdictionManager queryAudio:^(ZLPhotosSelectJurisdictionOpenState state) {
        UIView *optionsView = [weakSelf viewWithTag:86];
        UIButton *sender = optionsView.subviews[1];
        [weakSelf setMessageWithSender:sender state:state Key:@"录音"];
        [weakSelf gotoNextWithState:state];
    } ShowAlert:YES];
    [ZLPhotosSelectHardwareJurisdictionManager queryPhotoLibrary:^(ZLPhotosSelectJurisdictionOpenState state) {
        UIView *optionsView = [weakSelf viewWithTag:86];
        UIButton *sender = optionsView.subviews.lastObject;
        [weakSelf setMessageWithSender:sender state:state Key:@"相册"];
        [weakSelf gotoNextWithState:state];
    } ShowAlert:YES];
}
- (void)gotoNextWithState:(ZLPhotosSelectJurisdictionOpenState)state {
    if (state == ZLPhotosSelectJurisdictionOpenStateNormal) {
        self.normalCount = self.normalCount + 1;
    }
    //已经全部打开
    if (self.normalCount == 3) {
        //关闭窗口
        [self dismiss];
        //进行下一步操作
        if (self.results) {
            self.results();
        }
    }
}
- (void)setMessageWithSender:(UIButton *)sender state:(ZLPhotosSelectJurisdictionOpenState)state Key:(NSString *)key {
    UIImage *image = nil;
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    UIColor *color = UIColor.lightGrayColor;
    NSString *path = nil;
    if (state == ZLPhotosSelectJurisdictionOpenStateNormal) {
        color = ZLPhotosSelectConfig.shared.auth_alert_success_color ? ZLPhotosSelectConfig.shared.auth_alert_success_color : [UIColor colorWithRed:15 / 255.0 green:163 / 255.0 blue:94 / 255.0 alpha:1.0];
        path = [currentBundle.resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"ZLPhotosSelectViewController.bundle/%@@%dx.png", key, (int)UIScreen.mainScreen.scale]];
        [sender setTitle:[NSString stringWithFormat:@"  %@权限（已开启）",key] forState:UIControlStateNormal];
    }else if (state == ZLPhotosSelectJurisdictionOpenStateRefuseOpen) {
        color = ZLPhotosSelectConfig.shared.auth_alert_error_color ? ZLPhotosSelectConfig.shared.auth_alert_error_color : [UIColor colorWithRed:216 / 255.0 green:30 / 255.0 blue:6 / 255.0 alpha:1.0];
        path = [currentBundle.resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"ZLPhotosSelectViewController.bundle/%@@%dx.png", key, (int)UIScreen.mainScreen.scale]];
        [sender setTitle:[NSString stringWithFormat:@"  %@权限（已拒绝）",key] forState:UIControlStateNormal];
    }else {
        color = [UIColor colorWithWhite:112 / 255.0 alpha:1.0];
        path = [currentBundle.resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"ZLPhotosSelectViewController.bundle/%@@%dx.png", key, (int)UIScreen.mainScreen.scale]];
        [sender setTitle:[NSString stringWithFormat:@"  点击开启%@权限",key] forState:UIControlStateNormal];
    }
    image = [UIImage imageWithContentsOfFile:path];
    [image setValue:@(UIImageRenderingModeAlwaysTemplate) forKeyPath:@"renderingMode"];
    sender.imageView.tintColor = color;
    [sender setTitleColor:color forState:UIControlStateNormal];
    [sender setImage:image forState:UIControlStateNormal];
}
- (void)itemsAction:(UIButton *)sender {
    NSInteger index = [sender.superview.subviews indexOfObject:sender];
    __weak typeof(self)weakSelf = self;
    //相机
    if (!index) {
        [ZLPhotosSelectHardwareJurisdictionManager queryCamera:^(ZLPhotosSelectJurisdictionOpenState state) {
            UIView *optionsView = [weakSelf viewWithTag:86];
            UIButton *sender = optionsView.subviews.firstObject;
            [weakSelf setMessageWithSender:sender state:state Key:@"相机"];
        } ShowAlert:YES];
        return;
    }
    //录音
    if (index == 1) {
        [ZLPhotosSelectHardwareJurisdictionManager queryAudio:^(ZLPhotosSelectJurisdictionOpenState state) {
            UIView *optionsView = [weakSelf viewWithTag:86];
            UIButton *sender = optionsView.subviews[1];
            [weakSelf setMessageWithSender:sender state:state Key:@"录音"];
        } ShowAlert:YES];
        return;
    }
    //相册
    [ZLPhotosSelectHardwareJurisdictionManager queryPhotoLibrary:^(ZLPhotosSelectJurisdictionOpenState state) {
        UIView *optionsView = [weakSelf viewWithTag:86];
        UIButton *sender = optionsView.subviews.lastObject;
        [weakSelf setMessageWithSender:sender state:state Key:@"相册"];
    } ShowAlert:YES];
}

@end
