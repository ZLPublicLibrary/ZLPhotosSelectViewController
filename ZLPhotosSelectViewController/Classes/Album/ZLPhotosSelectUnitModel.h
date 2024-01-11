//
//  ZLPhotosSelectUnitModel.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectUnitModel : NSObject

///缩略图沙盒路径
@property (nonatomic,strong) NSString *filePath;
///缩略图沙盒名称
@property (nonatomic,strong) NSString *fileName;
///高清图沙盒路径
@property (nonatomic,strong) NSString *originalFilePath;
///高清图沙盒名称
@property (nonatomic,strong) NSString *originalFileName;
///压缩图沙盒路径
@property (nonatomic,strong) NSString *compressionFilePath;
///压缩图沙盒名称
@property (nonatomic,strong) NSString *compressionFileName;
///资源对象
@property (nonatomic,strong) PHAsset *asset;
///是否是动图
@property (nonatomic,unsafe_unretained) BOOL isGif;
///选中
@property (nonatomic,unsafe_unretained) BOOL select;


/**根据图片asset获取照片
 * original 原图
 * results 处理下文   result照片
*/
- (void)getPhotosWithOriginal:(BOOL)original Results:(void(^)(UIImage * _Nullable result))results;

/**根据图片asset获取gif数据
 * original 原图
 * results 处理下文   result gif数据
*/
- (void)getGifPhotosWithOriginal:(BOOL)original Results:(void(^)(NSData * _Nullable result))results;

@end

NS_ASSUME_NONNULL_END
