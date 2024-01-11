//
//  ZLPhotosSelectImageView.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotosSelectUnitModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectImageView : UIImageView

///根据图片模型加载图片
- (void)setImageWithUnitModel:(ZLPhotosSelectUnitModel *)unitModel;

@end

NS_ASSUME_NONNULL_END
