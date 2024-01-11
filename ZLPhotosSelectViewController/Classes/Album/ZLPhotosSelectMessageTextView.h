//
//  ZLPhotosSelectMessageTextView.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/4.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#define ZLShowMessage(message) [ZLPhotosSelectMessageTextView showMessage:message BanAutoDismiss:NO]

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectMessageTextView : UIView

/**展示提示信息
 @param message 提示语
 * BanAutoDismiss   禁止自动消失  默认：NO 不禁止
 */
+ (void)showMessage:(NSString *)message BanAutoDismiss:(BOOL)isBanAuto;

/**关闭提示
 */
+ (void)dismiss;

@end

NS_ASSUME_NONNULL_END
