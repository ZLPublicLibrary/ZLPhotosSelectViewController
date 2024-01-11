//
//  ZLPhotosSelectModel.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectModel.h"
#import "ZLPhotosSelectConfig.h"

@interface ZLPhotosSelectModel ()

///管理器
@property (nonatomic,strong) AVCaptureSession *session;

@end

@implementation ZLPhotosSelectModel

#pragma mark - LifeCycle
- (void)dealloc {
    if ([ZLPhotosSelectConfig shared].showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】main model object safe release");
    }
    if (self.previewLayer) {
        [self.session stopRunning];
        [self.previewLayer removeFromSuperlayer];
        if ([ZLPhotosSelectConfig shared].showDebugLog) {
            NSLog(@"【ZLPhotosSelectViewController】screenage preview object safe release");
        }
    }
}
+ (instancetype)loadMainModel {
    ZLPhotosSelectModel *mainModel = [self new];
    mainModel.didSelectedIdentifiers = [NSMutableArray new];
    ZLPhotosSelectUnitModel *unitModel = [ZLPhotosSelectUnitModel new];
    mainModel.unitModels = [NSMutableArray arrayWithObjects:unitModel, nil];
    mainModel.identifierSet = [NSMutableSet new];
    
    //事件
    __weak typeof(mainModel)weakSelf = mainModel;
    mainModel.loadPhotos = ^{
        [weakSelf loadPreviewLayer];
        [weakSelf loadPhotosAction];
    };
    return mainModel;
}

#pragma mark - Action
- (void)loadPreviewLayer {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.previewLayer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.reloadView) {
                    weakSelf.reloadView();
                }
            });
            return;
        }
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        self.session = session;
        if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [session setSessionPreset:AVCaptureSessionPreset1280x720];
        }
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
        [session startRunning];
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer = layer;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.reloadView) {
                weakSelf.reloadView();
            }
        });
    });
}
- (void)loadPhotosAction {
    @autoreleasepool {
        //分线程处理
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //遍历相册
            [weakSelf enumerateAssets];
            
            //调整数据
            [weakSelf fixData];
            
            //刷新UI
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (weakSelf.showDone) {
                    weakSelf.showDone(weakSelf.didSelectedIdentifiers.count);
                }
                if (weakSelf.reloadView) {
                    weakSelf.reloadView();
                }
            });
        });
    }
}

- (void)fixData {
    //如果已选照片从手机相册被删除，同步删除当前的选中索引
    for (NSInteger index = 0; index < self.didSelectedIdentifiers.count; index++) {
        NSString *identifier = self.didSelectedIdentifiers[index];
        if (![self.identifierSet containsObject:identifier]) {
            [self.didSelectedIdentifiers removeObject:identifier];
        }
    }
    //勾选上次选中的索引
    for (ZLPhotosSelectUnitModel *imageModel in self.unitModels) {
        if (ZLPhotosSelectConfig.shared.allowGIF) {
            //识别是不是gif
            if (@available(iOS 9, *)) {
                PHAssetResource *resource = [PHAssetResource assetResourcesForAsset:imageModel.asset].firstObject;
                imageModel.isGif = [resource.uniformTypeIdentifier isEqualToString:@"com.compuserve.gif"];
            } else {
                 NSString *filename = [imageModel.asset valueForKey:@"filename"];
                imageModel.isGif = [filename rangeOfString:@".gif"].location != NSNotFound;
            }
        }
        //识别是不是上次已经勾选的
        if ([self.didSelectedIdentifiers containsObject:imageModel.asset.localIdentifier]) {
            imageModel.select = YES;
        }
    }
}

/*  遍历相簿中的全部图片
*/
- (void)enumerateAssets {
    @autoreleasepool {
        //拿到所有的相簿
        NSMutableArray *arrayM = [NSMutableArray new];
        
        //获得所有的自定义相簿
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        //遍历所有的自定义相簿
        for (PHAssetCollection *assetCollection in assetCollections) {
            // 获得某个相簿中的所有PHAsset对象
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            for (NSInteger index = 0; index < assets.count; index++) {
                PHAsset *asset = assets[index];
                [arrayM addObject:asset];
            }
        }
        
        //获得相机胶卷
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        // 获得某个相簿中的所有PHAsset对象
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
        for (NSInteger index = 0; index < assets.count; index++) {
            PHAsset *asset = assets[index];
            [arrayM addObject:asset];
        }
        
        // 获得某个相簿中的所有PHAsset对象
        for (NSInteger index = 0; index < arrayM.count; index++) {
            PHAsset *asset = arrayM[index];
            if ([self.identifierSet containsObject:asset.localIdentifier]) {
                continue;
            }
            [self.identifierSet addObject:asset.localIdentifier];
            __block ZLPhotosSelectUnitModel *imageModel = [ZLPhotosSelectUnitModel new];
            imageModel.asset = asset;
            [self.unitModels insertObject:imageModel atIndex:1];
        }
    }
}

@end
