//
//  ZLPhotosSelectSandboxManager.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectSandboxManager.h"
#import "ZLPhotosSelectConfig.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation ZLPhotosSelectSandboxManager

#pragma mark - LifeCycle
- (void)dealloc {
    if ([ZLPhotosSelectConfig shared].showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】sandbox manager object safe release");
    }
}
- (instancetype)init {
    if (self = [super init]) {
        if ([ZLPhotosSelectConfig shared].showDebugLog) {
            NSString *imgDiretory = [self loadSandboxFilePathWithOriginal:ZLPhotosTypeThumbnail];
            NSLog(@"【ZLPhotosSelectViewController】sandbox path : %@",imgDiretory);
        }
    }
    return self;
}

#pragma mark - Action

/**删除沙盒中缓存照片（全部删除）
 * original 图片的类型
*/
- (void)removeAllSandboxCachePhotosWithOriginal:(ZLPhotosType)original {
    if (original != ZLPhotosTypeAll) {
        NSString *imgDiretory = [self loadSandboxFilePathWithOriginal:original];
        NSError *errorMessage = nil;
        BOOL error = ![[NSFileManager defaultManager] removeItemAtPath:imgDiretory error:&errorMessage];
        if ([ZLPhotosSelectConfig shared].showDebugLog) {
            NSString *errorStirng = nil;
            if (error) {
                errorStirng = [[NSString alloc] initWithData:errorMessage.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
            }
            NSString *key = nil;
            if (original == ZLPhotosTypeThumbnail) {
                key = @"Thumbnail";
            }else if (original == ZLPhotosTypeOriginal) {
                key = @"Original";
            }else {
                key = @"Compression";
            }
            NSLog(@"【ZLPhotosSelectViewController】%@ photos remove %@%@", key,error ? @"failed" : @"successed",error ? [NSString stringWithFormat:@"，ERROR:%@",errorStirng] : @"");
        }
        return;
    }
    NSArray *array = @[@"0",@"1",@"2"];
    NSInteger index = 0;
    while (index < array.count) {
        ZLPhotosType currentOriginal = [array[index] integerValue];
        NSString *imgDiretory = [self loadSandboxFilePathWithOriginal:currentOriginal];
        NSError *errorMessage = nil;
        BOOL error = ![[NSFileManager defaultManager] removeItemAtPath:imgDiretory error:&errorMessage];
        if ([ZLPhotosSelectConfig shared].showDebugLog) {
            NSString *errorStirng = nil;
            if (error) {
                errorStirng = [[NSString alloc] initWithData:errorMessage.userInfo[@"com.alamofire.serialization.response.error.data"] encoding:NSUTF8StringEncoding];
            }
            NSString *key = nil;
            if (currentOriginal == ZLPhotosTypeThumbnail) {
                key = @"Thumbnail";
            }else if (currentOriginal == ZLPhotosTypeOriginal) {
                key = @"Original";
            }else {
                key = @"Compression";
            }
            NSLog(@"【ZLPhotosSelectViewController】%@ photos remove %@%@", key,error ? @"failed" : @"successed",error ? [NSString stringWithFormat:@"，ERROR:%@",errorStirng] : @"");
        }
        index++;
    }
}

/**获取照片沙盒文件夹路径
 * original 图片的类型
 * return 文件夹路径
*/
- (NSString *)loadSandboxFilePathWithOriginal:(ZLPhotosType)original {
    NSString *sandboxPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *key = nil;
    if (original == ZLPhotosTypeThumbnail) {
        key = @"Thumbnail";
    }else if (original == ZLPhotosTypeOriginal) {
        key = @"Original";
    }else {
        key = @"Compression";
    }
    NSString *imgDiretory = [sandboxPath stringByAppendingPathComponent:[NSString stringWithFormat:@"ZL%@PhotoFiles",key]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imgDiretory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imgDiretory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return imgDiretory;
}

/**获取根据要求获取照片在沙盒中的全路径
 * identifier 唯一标识
    * 当original == ZLPhotosTypeThumbnail时，identifier为相册asset的localIdentifier
    * 其他情况（ZLPhotosTypeOriginal、ZLPhotosTypeCompression）时，identifier会在内部进行重定向，会被赋值为随机唯一字符串（UUID+1970时间戳）
 * original 图片的类型
 * suffixType 后缀的类型
 * return 照片在沙盒中的全路径
*/
- (NSString *)loadSandboxFilePathWithIdentifier:(NSString *)identifier Original:(ZLPhotosType)original SuffixType: (ZLPhotosSuffixType)suffixType {
    NSString *imgDiretory = [self loadSandboxFilePathWithOriginal:original];
    if (original == ZLPhotosTypeOriginal || original == ZLPhotosTypeCompression) {
        identifier = [NSString stringWithFormat:@"%@%f",NSUUID.UUID.UUIDString,[[NSDate date] timeIntervalSince1970]];
    }
    identifier = [self MD5For32Bate:identifier SuffixType:suffixType];
    NSString *imgPath = [imgDiretory stringByAppendingPathComponent:identifier];
    return imgPath;
}

/**分线程将照片按照指定名称写入沙盒
 * identifier 唯一标识
 * suffixType 后缀的类型
 * original 图片的类型
 * results 完成后的事件   imgPath:写入的照片路径
 */
- (void)writePhotosInSandboxWithIdentifier:(NSString *)identifier Image:(id)image Original:(ZLPhotosType)original SuffixType: (ZLPhotosSuffixType)suffixType Results:(void(^)(NSString *imgPath))results {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *imgPath = [self loadSandboxFilePathWithIdentifier:identifier Original:original SuffixType:suffixType];
        NSData *data = nil;
        if ([image isKindOfClass:[UIImage class]]) {
            if (suffixType == ZLPhotosSuffixTypeJpeg) {
                data = UIImageJPEGRepresentation(image, 1.0);
            }else {
                data = UIImagePNGRepresentation(image);
            }
        }else {
            data = image;
        }
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:imgPath];
        if (isExists) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (results) {
                    results(imgPath);
                }
            });
            return ;
        }
        BOOL error = ![data writeToFile:imgPath atomically:YES];
        if ([ZLPhotosSelectConfig shared].showDebugLog) {
            NSLog(@"【ZLPhotosSelectViewController】write photos on :%@. write %@", [NSThread currentThread], error ? @"failed" : @"successed");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (results) {
                results(error ? nil : imgPath);
            }
        });
    });
}

///MD5加密 32位 小写
- (NSString *)MD5For32Bate:(NSString *)string SuffixType: (ZLPhotosSuffixType)suffixType {
    const char *input = [string UTF8String];
    unsigned char digest[16];
    CC_MD5(input,(CC_LONG)strlen(input),digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    if (suffixType == ZLPhotosSuffixTypePng) {
        return [NSString stringWithFormat:@"%@%@",output, @".png"];
    }else if (suffixType == ZLPhotosSuffixTypeJpeg) {
        return [NSString stringWithFormat:@"%@%@",output, @".jpeg"];
    }else if (suffixType == ZLPhotosSuffixTypeGif) {
        return [NSString stringWithFormat:@"%@%@",output, @".gif"];
    }else if (suffixType == ZLPhotosSuffixTypeJson) {
        return [NSString stringWithFormat:@"%@%@",output, @".json"];
    }
    return [NSString stringWithFormat:@"%@%@",output, @""];
}

@end
