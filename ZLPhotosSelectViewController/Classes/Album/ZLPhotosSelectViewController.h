//
//  ZLPhotosSelectViewController.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotosSelectUnitModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectViewController : UIViewController

///上次已经选中的图片
@property (nonatomic,strong) NSArray <ZLPhotosSelectUnitModel *>*lastSelectedPhotos;

///本此选中的照片
@property (nonatomic,copy) void (^didSelectedPhotos)(NSArray <ZLPhotosSelectUnitModel *>*images);
///左边按钮的事件
@property (nonatomic,copy) void (^leftItemAction)(void);

@end

NS_ASSUME_NONNULL_END
