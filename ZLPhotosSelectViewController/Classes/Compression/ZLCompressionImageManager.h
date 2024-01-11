//
//  ZLCompressionImageManager.h
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/5.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLCompressionImageManager : NSObject

/**压缩尺寸算法（该算法高仿微信）
 * image 将要压缩的图片
 */
+ (CGSize)compressionSizeWithImage:(UIImage *)image;

/**压缩图片
 * image 将要压缩的图片
 * results 处理下文   result 压缩后的图片
 */
+ (void)compressionImage:(UIImage *)image Results:(void(^)(UIImage *result))results;

@end

NS_ASSUME_NONNULL_END
