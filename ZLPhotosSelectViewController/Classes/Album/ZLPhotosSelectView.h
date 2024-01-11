//
//  ZLPhotosSelectView.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotosSelectModel.h"
#import "ZLPhotosSelectNavBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectView : UIView

///主模型
@property (nonatomic,strong) ZLPhotosSelectModel *mainModel;
///顶部导航条
@property (nonatomic,weak) ZLPhotosSelectNavBar *navBar;

@end

NS_ASSUME_NONNULL_END
