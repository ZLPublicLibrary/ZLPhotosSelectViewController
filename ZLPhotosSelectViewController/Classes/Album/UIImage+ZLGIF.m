//
//  UIImage+ZLGIF.m
//  Pods-ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/15.
//

#import "UIImage+ZLGIF.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation UIImage (ZLGIF)

///根据data加载gif
+ (UIImage *)animatedGIFWithData:(NSData *)data {
    @autoreleasepool {
        if (!data) {
            return nil;
        }
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        size_t count = CGImageSourceGetCount(source);
        UIImage *animatedImage;
        if (count <= 1) {
            animatedImage = [[UIImage alloc] initWithData:data];
        }else {
            NSMutableArray *images = [NSMutableArray array];
            NSTimeInterval duration = 0.0f;
            for (size_t i = 0; i < count; i++) {
                CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
                duration += [self frameDurationAtIndex:i source:source];
                [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
                CGImageRelease(image);
            }
            if (!duration) {
                duration = 0.05f * count;
            }
            animatedImage = [UIImage animatedImageWithImages:images duration:duration];
        }
        CFRelease(source);
        return animatedImage;
    };
}

///裁剪gif数据，可调控大小
+ (NSData *)scallGIFWithData:(NSData *)data scallSize:(CGSize)scallSize {
    @autoreleasepool {
        if (!data) {
            return nil;
        }
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
        size_t count = CGImageSourceGetCount(source);
        NSDictionary *fileProperties = [self filePropertiesWithLoopCount:0];
        NSString *tempFile = [NSTemporaryDirectory() stringByAppendingString:@"scallTemp.gif"];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:tempFile]) {
            [manager removeItemAtPath:tempFile error:nil];
        }
        NSURL *fileUrl = [NSURL fileURLWithPath:tempFile];
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileUrl, kUTTypeGIF , count, NULL);
        NSTimeInterval duration = 0.0f;
        for (size_t i = 0; i < count; i++) {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            UIImage *scallImage = [image scallImageWidthScallSize:scallSize];
            NSTimeInterval delayTime = [self frameDurationAtIndex:i source:source];
            duration += delayTime;
            NSDictionary *frameProperties = [self framePropertiesWithDelayTime:delayTime];
            CGImageDestinationAddImage(destination, scallImage.CGImage, (CFDictionaryRef)frameProperties);
            CGImageRelease(imageRef);
        }
        CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
        if (!CGImageDestinationFinalize(destination)) {
            NSLog(@"Failed to finalize GIF destination");
            if (destination != nil) {
              CFRelease(destination);
            }
            return nil;
        }
        CFRelease(destination);
        CFRelease(source);
        return [NSData dataWithContentsOfFile:tempFile];
    };
}

- (UIImage *)scallImageWidthScallSize:(CGSize)scallSize{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = scallSize.width;
    CGFloat scaledHeight = scallSize.height;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (!CGSizeEqualToSize(self.size, scallSize)) {
        CGFloat widthFactor = scaledWidth / width;
        CGFloat heightFactor = scaledHeight / height;
        scaleFactor = MAX(widthFactor, heightFactor);
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if (widthFactor > heightFactor) {
          thumbnailPoint.y = (scallSize.height - scaledHeight) * 0.5;
        }else if (widthFactor < heightFactor) {
          thumbnailPoint.x = (scallSize.width - scaledWidth) * 0.5;
        }
    }
    CGRect rect;
    rect.origin = thumbnailPoint;
    rect.size = CGSizeMake(scaledWidth, scaledHeight);
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
    UIImage *newImage = [UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:self.imageOrientation];
    [newImage drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
}

//根据索引，获取每帧所需时长
+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.05f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
      frameDuration = [delayTimeUnclampedProp floatValue];
    }else {
      NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
      if (delayTimeProp) {
        frameDuration = [delayTimeProp floatValue];
      }
    }
    if (frameDuration < 0.1) {
      frameDuration = 0.1;
    }else {
        frameDuration -= 0.3;
    }
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (NSDictionary *)filePropertiesWithLoopCount:(int)loopCount {
    return @{(NSString *)kCGImagePropertyGIFDictionary: @{(NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}};
}
+ (NSDictionary *)framePropertiesWithDelayTime:(NSTimeInterval)delayTime {
    return @{(NSString *)kCGImagePropertyGIFDictionary:@{(NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},(NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB};
}

@end
