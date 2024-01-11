//
//  ZLPhotosSelectModel.h
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLPhotosSelectUnitModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZLPhotosSelectModel : NSObject

///影像的预览层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

///标识库
@property (nonatomic,strong) NSMutableSet <NSString *>*identifierSet;

///上次已经选中的图片
@property (nonatomic,strong) NSArray <ZLPhotosSelectUnitModel *>*lastSelectedPhotos;
///单元模型
@property (nonatomic,strong) NSMutableArray <ZLPhotosSelectUnitModel *>*unitModels;

///已经选中的图片标识
@property (nonatomic,strong) NSMutableArray <NSString *>*didSelectedIdentifiers;

///左边按钮的事件
@property (nonatomic,copy) void (^leftItemAction)(void);
///视图里的重置事件
@property (nonatomic,copy) void (^reloadView)(void);
///展示确定按钮
@property (nonatomic,copy) void (^showDone)(BOOL show);
///视图里的重置事件
@property (nonatomic,copy) void (^loadPhotos)(void);
///拍照
@property (nonatomic,copy) void (^shoot)(void);
///本此选中的照片
@property (nonatomic,copy) void (^didSelectedPhotos)(NSArray <ZLPhotosSelectUnitModel *>*images);

///加载主模型
+ (instancetype)loadMainModel;

@end

NS_ASSUME_NONNULL_END
