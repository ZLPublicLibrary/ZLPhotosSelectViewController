//
//  ZLPhotosSelectView.m
//  ZLPhotosSelectViewControllerDemo_Example
//
//  Created by 赵磊 on 2020/6/3.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLPhotosSelectView.h"
#import "ZLPhotosSelectConfig.h"
#import "ZLPhotosSelectCell.h"

@interface ZLPhotosSelectView ()<UICollectionViewDataSource,UICollectionViewDelegate>

///表视图
@property (nonatomic,weak) UICollectionView *collectionView;

@end

@implementation ZLPhotosSelectView

#pragma mark - LifeCycle
- (void)dealloc {
    if ([ZLPhotosSelectConfig shared].showDebugLog) {
        NSLog(@"【ZLPhotosSelectViewController】content view object safe release");
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        [self navBar];
    }
    return self;
}

#pragma mark - Set
- (void)setMainModel:(ZLPhotosSelectModel *)mainModel {
    _mainModel = mainModel;
    [self registerAction];
}

#pragma mark - Lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        BOOL isBangDevice = NO;
        if (@available(iOS 11.0, *)) {
            isBangDevice = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
        }
        CGFloat navigationHeight = isBangDevice ? 84.0 : 64.0;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 5.0;
        layout.minimumInteritemSpacing = 5.0;
        layout.itemSize = CGSizeMake((self.frame.size.width - 25.0) / 4, (self.frame.size.width - 25.0) / 4);
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, navigationHeight, self.frame.size.width, self.frame.size.height - navigationHeight) collectionViewLayout:layout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
        
        //ios11 适配
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            collectionView.scrollIndicatorInsets = collectionView.contentInset;
        }
        
        [collectionView registerClass:[ZLPhotosSelectCell class] forCellWithReuseIdentifier:NSStringFromClass([ZLPhotosSelectCell class])];
        [self addSubview:collectionView];
        [self sendSubviewToBack:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}
- (ZLPhotosSelectNavBar *)navBar {
    if (!_navBar) {
        BOOL isBangDevice = NO;
        if (@available(iOS 11.0, *)) {
            isBangDevice = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
        }
        CGFloat navigationHeight = isBangDevice ? 84.0 : 64.0;
        ZLPhotosSelectNavBar *navBar = [[ZLPhotosSelectNavBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, navigationHeight)];
        [self addSubview:navBar];
        _navBar = navBar;
        
        //事件
        __weak typeof(self)weakSelf = self;
        navBar.leftItemAction = ^{
            if (weakSelf.mainModel.leftItemAction) {
                weakSelf.mainModel.leftItemAction();
            }
        };
        navBar.rightItemAction = ^{
            NSMutableArray *arrayM = [NSMutableArray new];
            NSMutableDictionary *dictM = [NSMutableDictionary new];
            for (ZLPhotosSelectUnitModel *imageModel in weakSelf.mainModel.unitModels) {
                if (!imageModel.asset) {
                    continue;
                }
                if ([weakSelf.mainModel.didSelectedIdentifiers containsObject:imageModel.asset.localIdentifier]) {
                    dictM[imageModel.asset.localIdentifier] = imageModel;
                }
            }
            for (NSInteger index = 0; index < weakSelf.mainModel.didSelectedIdentifiers.count; index++) {
                NSString *key = weakSelf.mainModel.didSelectedIdentifiers[index];
                [arrayM addObject:dictM[key]];
            }
            if (weakSelf.mainModel.didSelectedPhotos) {
                weakSelf.mainModel.didSelectedPhotos(arrayM);
            }
        };
    }
    return _navBar;
}

#pragma mark - Action
- (void)registerAction {
    __weak typeof(self)weakSelf = self;
    self.mainModel.reloadView = ^{//展示数据
        [weakSelf.collectionView reloadData];
    };
    self.mainModel.showDone = ^(BOOL show) {
        if (ZLPhotosSelectConfig.shared.maxCount == 1) {
            return ;
        }
        weakSelf.navBar.rightButton.hidden = !show;
    };
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mainModel.unitModels.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZLPhotosSelectCell *cell = (ZLPhotosSelectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZLPhotosSelectCell class]) forIndexPath:indexPath];
    ZLPhotosSelectUnitModel *unitModel = self.mainModel.unitModels[indexPath.row];
    if (!unitModel.asset) {
        cell.hudView.hidden = NO;
        cell.markButton.selected = NO;
        cell.markButton.frame = cell.imageView.frame;
        cell.imageView.image = nil;
        [cell.markButton setImage:ZLPhotosSelectConfig.shared.cameraMarkIcon forState:UIControlStateNormal];
        self.mainModel.previewLayer.frame = cell.imageView.frame;
        cell.markButton.layer.cornerRadius = 0;
        cell.markButton.backgroundColor = UIColor.clearColor;
        [cell.markButton setTitle:nil forState:UIControlStateNormal];
        cell.markButton.layer.borderColor = UIColor.whiteColor.CGColor;
        [cell.hudView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [cell.hudView.layer addSublayer:self.mainModel.previewLayer];
    }else {
        [cell.imageView setImageWithUnitModel:unitModel];
        cell.hudView.hidden = !unitModel.select;
        cell.markButton.selected = unitModel.select;
        [cell.markButton setImage:nil forState:UIControlStateNormal];
        cell.markButton.frame = CGRectMake(CGRectGetWidth(cell.imageView.frame) - 25.0, 5.0, 20.0, 20.0);
        cell.markButton.layer.cornerRadius = CGRectGetHeight(cell.markButton.frame) / 2;
        cell.markButton.layer.borderColor = (cell.markButton.selected ? ZLPhotosSelectConfig.shared.mainColor : [UIColor.lightGrayColor colorWithAlphaComponent:0.5]).CGColor;
        cell.markButton.backgroundColor = (cell.markButton.selected ? ZLPhotosSelectConfig.shared.mainColor : [UIColor.whiteColor colorWithAlphaComponent:0.3]);
        NSString *title = [NSString stringWithFormat:@"%ld",[self.mainModel.didSelectedIdentifiers indexOfObject:unitModel.asset.localIdentifier] + 1];
        [cell.markButton setTitle:unitModel.select ? title : nil forState:UIControlStateNormal];
        [cell.hudView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    }
    if (ZLPhotosSelectConfig.shared.maxCount == 1) {
        //单选
        if (!indexPath.row) {
            cell.markButton.hidden = NO;
        }else {
            cell.markButton.hidden = YES;
        }
    }else {
        //多选
        cell.markButton.hidden = NO;
    }
    return cell;
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZLPhotosSelectUnitModel *currentModel = self.mainModel.unitModels[indexPath.row];
    if (!currentModel.asset) {
        if (self.mainModel.didSelectedIdentifiers.count >= ZLPhotosSelectConfig.shared.maxCount) {
            NSString *message = [NSString stringWithFormat:@"最多只能选%ld张",ZLPhotosSelectConfig.shared.maxCount];
            ZLShowMessage(message);
            return;
        }
        if (self.mainModel.shoot) {
            self.mainModel.shoot();
        }
        return;
    }
    //单选
    if (ZLPhotosSelectConfig.shared.maxCount == 1) {
        [self.mainModel.didSelectedIdentifiers addObject:currentModel.asset.localIdentifier];
        if (self.mainModel.didSelectedPhotos) {
            self.mainModel.didSelectedPhotos(@[currentModel]);
        }
        return;
    }
    //多选
    if (!currentModel.select) {
        if (self.mainModel.didSelectedIdentifiers.count >= ZLPhotosSelectConfig.shared.maxCount) {
            NSString *message = [NSString stringWithFormat:@"最多只能选%ld张",ZLPhotosSelectConfig.shared.maxCount];
            ZLShowMessage(message);
            return;
        }
    }
    if (!currentModel.select && !currentModel.filePath) {
        ZLShowMessage(@"请稍等，图片正在加载中……");
        return;
    }
    currentModel.select = !currentModel.select;
    if (currentModel.select) {
        [self.mainModel.didSelectedIdentifiers addObject:currentModel.asset.localIdentifier];
    }else {
        [self.mainModel.didSelectedIdentifiers removeObject:currentModel.asset.localIdentifier];
    }
    if (self.mainModel.showDone) {
        self.mainModel.showDone(self.mainModel.didSelectedIdentifiers.count);
    }
    [collectionView reloadData];
}

@end
