//
//  ZLPhotosSelectSandboxManager.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

///图片类型
typedef NS_ENUM (NSInteger , ZLPhotosType){
    ///缩略图
    ZLPhotosTypeThumbnail = 0,
    ///高清大图
    ZLPhotosTypeOriginal,
    ///智能压缩
    ZLPhotosTypeCompression,
    ///所有图片（指定用于清理缓存时）
    ZLPhotosTypeAll,
};

/// 后缀类型
typedef NS_ENUM (NSInteger , ZLPhotosSuffixType){
    /// 未知的
    ZLPhotosSuffixTypeUnknown = 0,
    /// png
    ZLPhotosSuffixTypePng,
    /// jpeg
    ZLPhotosSuffixTypeJpeg,
    /// gif
    ZLPhotosSuffixTypeGif,
    /// json
    ZLPhotosSuffixTypeJson,
};

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectSandboxManager : NSObject

/**删除沙盒中缓存照片（全部删除）
 * original 图片的类型
*/
- (void)removeAllSandboxCachePhotosWithOriginal:(ZLPhotosType)original;

/**获取根据要求获取照片在沙盒中的全路径
 * identifier 唯一标识
    * 当original == ZLPhotosTypeThumbnail时，identifier为相册asset的localIdentifier
    * 其他情况（ZLPhotosTypeOriginal、ZLPhotosTypeCompression）时，identifier会在内部进行重定向，会被赋值为随机唯一字符串（UUID+1970时间戳）
 * original 图片的类型
 * suffixType 后缀的类型
 * return 照片在沙盒中的全路径
*/
- (NSString *)loadSandboxFilePathWithIdentifier:(NSString *)identifier Original:(ZLPhotosType)original SuffixType: (ZLPhotosSuffixType)suffixType;

/**分线程将照片按照指定名称写入沙盒
 * identifier 唯一标识
 * suffixType 后缀的类型
 * original 图片的类型
 * results 完成后的事件   imgPath:写入的照片路径
 */
- (void)writePhotosInSandboxWithIdentifier:(NSString *)identifier Image:(id)image Original:(ZLPhotosType)original SuffixType: (ZLPhotosSuffixType)suffixType Results:(void(^)(NSString *imgPath))results;

@end

NS_ASSUME_NONNULL_END
