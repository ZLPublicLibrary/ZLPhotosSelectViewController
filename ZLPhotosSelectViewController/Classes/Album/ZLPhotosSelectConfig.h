//
//  ZLPhotosSelectConfig.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLPhotosSelectSandboxManager.h"
#import "ZLPhotosSelectMessageTextView.h"
#import "ZLOperationProgressBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectConfig : NSObject

/* ---------------- 2.0 -------------------*/

///调试日志（YES:展示  NO:不展示   默认:NO不展示）
@property (nonatomic,unsafe_unretained) BOOL showDebugLog;

///允许gif选择
@property (nonatomic,unsafe_unretained) BOOL allowGIF;

///最大选中量
@property (nonatomic,unsafe_unretained) NSInteger maxCount;

///主题色
@property (nonatomic,strong) UIColor *mainColor;

///操作进度条
@property (nonatomic,strong,nullable) ZLOperationProgressBar *progressBar;

/**指定最大缩略图获取的单倍像素标线
 * 该值非绝对值，但得到的单倍像素点一定会比该值小
 * 比如：在6s手机上，该设备是2倍屏，所得到的图片尺寸会比maxPoint * 2小。
 * 默认：90.0
*/
@property (nonatomic,unsafe_unretained) CGFloat thumbnailMaxPoint;

///这里尽量使用imageWithContentsOfFile赋值，因为只使用一次，让内存可以得到释放
@property (nonatomic,strong) UIImage *cameraMarkIcon;

///沙盒管理器（该管理器仅对当前组件产生的数据有效）
@property (nonatomic,strong,nullable) ZLPhotosSelectSandboxManager *sandboxManager;


///单例
+ (instancetype)shared;


/* ---------------- 3.0 -------------------*/


/// 授权描述
@property (nonatomic,strong, nullable) NSString *auth_alert_remaks;
/// 授权成功的文字颜色
@property (nonatomic,strong, nullable) UIColor *auth_alert_success_color;
/// 授权失败的文字颜色
@property (nonatomic,strong, nullable) UIColor *auth_alert_error_color;


@end

NS_ASSUME_NONNULL_END
