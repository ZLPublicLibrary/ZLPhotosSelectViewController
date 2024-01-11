//
//  ZLPhotosSelectViewController.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectViewController.h"
#import "ZLPhotosSelectView.h"
#import "ZLPhotosSelectConfig.h"
#import "ZLPhotosSelectSandboxManager.h"
#import "ZLPhotosSelectHardwareJurisdictionManager.h"

@interface ZLPhotosSelectViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

///内容视图
@property (nonatomic,weak) ZLPhotosSelectView *contentView;

@end

@implementation ZLPhotosSelectViewController

#pragma mark - LifeCycle
- (void)dealloc {
    if ([ZLPhotosSelectConfig shared].showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】view controller object safe release");
    }
}
- (instancetype)init {
    if (self = [super init]) {
        self.view.backgroundColor = UIColor.whiteColor;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    ZLPhotosSelectConfig.shared.sandboxManager = [ZLPhotosSelectSandboxManager new];
    self.contentView.mainModel = [ZLPhotosSelectModel loadMainModel];
    [self queryHardwareJurisdiction];
    [self registerAction];
}

#pragma mark - Set
- (void)setLeftItemAction:(void (^)(void))leftItemAction {
    _leftItemAction = leftItemAction;
    self.contentView.mainModel.leftItemAction = leftItemAction;
}
- (void)setLastSelectedPhotos:(NSArray<ZLPhotosSelectUnitModel *> *)lastSelectedPhotos {
    _lastSelectedPhotos = lastSelectedPhotos;
    [self.contentView.mainModel.didSelectedIdentifiers removeAllObjects];
    self.contentView.mainModel.lastSelectedPhotos = lastSelectedPhotos;
    for (NSInteger index = 0; index < lastSelectedPhotos.count; index++) {
        ZLPhotosSelectUnitModel *unitModel = lastSelectedPhotos[index];
        [self.contentView.mainModel.didSelectedIdentifiers addObject:unitModel.asset.localIdentifier];
    }
}
- (void)setDidSelectedPhotos:(void (^)(NSArray<ZLPhotosSelectUnitModel *> * _Nonnull))didSelectedPhotos {
    _didSelectedPhotos = didSelectedPhotos;
    self.contentView.mainModel.didSelectedPhotos = didSelectedPhotos;
}

#pragma mark - Lazy
- (ZLPhotosSelectView *)contentView {
    if (!_contentView) {
        ZLPhotosSelectView *view = [[ZLPhotosSelectView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [self.view addSubview:view];
        _contentView = view;
    }
    return _contentView;
}

#pragma mark - Action
- (void)registerAction {
    __weak typeof(self)weakSelf = self;
    self.contentView.mainModel.shoot = ^{
        if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"当前为模拟器环境，未找到设备摄像头" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return ;
        }
        //摄像头
        UIImagePickerController *imagePc = [[UIImagePickerController alloc] init];
        imagePc.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePc.delegate = weakSelf;
        imagePc.modalPresentationStyle = UIModalPresentationFullScreen;
        [weakSelf presentViewController:imagePc animated:YES completion:nil];
    };
}
- (void)queryHardwareJurisdiction {
    //查询权限是否已经全部打开
    __weak typeof(self)weakSelf = self;
    [ZLPhotosSelectHardwareJurisdictionManager queryWithResults:^(ZLPhotosSelectHardwareJurisdictionState state) {
            if (state == ZLPhotosSelectHardwareJurisdictionStateNullCamera) {//未识别到摄像头
                ZLShowMessage(@"未识别到设备摄像头");
                if (weakSelf.contentView.mainModel.leftItemAction) {
                    weakSelf.contentView.mainModel.leftItemAction();
                }
                return ;
            }
            if (state == ZLPhotosSelectHardwareJurisdictionStateNormal) {//已经全部开启权限
                if (weakSelf.contentView.mainModel.loadPhotos) {
                    weakSelf.contentView.mainModel.loadPhotos();
                }
                return;
            }
            //未全部开启权限
            [ZLPhotosSelectHardwareJurisdictionManager showOnView:weakSelf.view Results:^{
                if (weakSelf.contentView.mainModel.loadPhotos) {
                    weakSelf.contentView.mainModel.loadPhotos();
                }
            } Dismiss:^{}];
    }];
}

///拍照后的回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //保存
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

///保存图片后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        ZLShowMessage(@"保存照片到相册失败");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"图片保存到失败！可能是没有足够的内存来承载照片导致" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault
           handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    @autoreleasepool {
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:cameraRoll options:nil];
        PHAsset *asset = assets.lastObject;
        __block ZLPhotosSelectUnitModel *unitModel = [ZLPhotosSelectUnitModel new];
        unitModel.asset = asset;
        unitModel.select = YES;
        if (ZLPhotosSelectConfig.shared.maxCount != 1) {
            //防越界处理
            if (self.contentView.mainModel.unitModels.count > 2) {
                [self.contentView.mainModel.unitModels insertObject:unitModel atIndex:1];
            }else {
                [self.contentView.mainModel.unitModels addObject:unitModel];
            }
            if (self.contentView.mainModel.showDone) {
                self.contentView.mainModel.showDone(YES);
            }
            [self.contentView.mainModel.didSelectedIdentifiers addObject:unitModel.asset.localIdentifier];
            if (self.contentView.mainModel.reloadView) {
                self.contentView.mainModel.reloadView();
            }
            return;
        }
        __weak typeof(self)weakSelf = self;
        //获取拍照后的照片
        [unitModel getPhotosWithOriginal:NO Results:^(UIImage * _Nullable result) {
            if (!result) {
                return;
            }
            //将照片写入沙盒保存
            [ZLPhotosSelectConfig.shared.sandboxManager writePhotosInSandboxWithIdentifier:unitModel.asset.localIdentifier Image:result Original:ZLPhotosTypeThumbnail SuffixType:ZLPhotosSuffixTypeJpeg Results:^(NSString * _Nonnull imgPath) {
                unitModel.filePath = imgPath;
                if (weakSelf.contentView.mainModel.didSelectedPhotos) {
                    weakSelf.contentView.mainModel.didSelectedPhotos(@[unitModel]);
                }
            }];
        }];
    };
}

@end
