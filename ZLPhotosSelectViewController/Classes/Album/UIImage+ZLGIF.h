//
//  UIImage+ZLGIF.h
//  Pods-ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ZLGIF)

///根据data加载gif
+ (UIImage *)animatedGIFWithData:(NSData *)data;

///裁剪gif数据，可调控大小
+ (NSData *)scallGIFWithData:(NSData *)data scallSize:(CGSize)scallSize;

@end

NS_ASSUME_NONNULL_END
