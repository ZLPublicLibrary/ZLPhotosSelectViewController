//
//  ZLSimulationUseViewController.m
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/10.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLSimulationUseViewController.h"
#import <ZLPhotosSelectHeader.h>

@interface ZLSimulationUseViewController ()

///操作事件
@property (nonatomic,weak) UIButton *operationButton;
///操作信息
@property (nonatomic,weak) UILabel *operationMessageLabel;
///当前选中的图片数据
@property (nonatomic,strong) NSArray<ZLPhotosSelectUnitModel *> *images;

@end

@implementation ZLSimulationUseViewController

- (void)dealloc {
    //在一个上传周期完全结束后，释放因选择图片产生的沙盒数据。
    [ZLPhotosSelectConfig.shared.sandboxManager removeAllSandboxCachePhotosWithOriginal:(ZLPhotosTypeAll)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    //配置项一定要写在最前，避免出现问题
    ZLPhotosSelectConfig.shared.showDebugLog = NO;
    ZLPhotosSelectConfig.shared.maxCount = 4;
    ZLPhotosSelectConfig.shared.allowGIF = YES;
    
    [self operationButton];
}

#pragma mark - Lazy
- (UIButton *)operationButton {
    if (!_operationButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15.0, 40.0, UIScreen.mainScreen.bounds.size.width - 30.0, 45.0)];
        button.backgroundColor = UIColor.cyanColor;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.7].CGColor;
        button.layer.cornerRadius = CGRectGetHeight(button.frame) / 2;
        button.layer.masksToBounds = YES;
        [button setTitle:@"一键测试选择照片操作流程" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [button addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _operationButton = button;
    }
    return _operationButton;
}
- (UILabel *)operationMessageLabel {
    if (!_operationMessageLabel) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.operationButton.frame) + 30.0, UIScreen.mainScreen.bounds.size.width - 30.0, 80.0)];
        view.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
        view.layer.cornerRadius = 3.0;
        view.layer.masksToBounds = YES;
        [self.view addSubview:view];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, UIScreen.mainScreen.bounds.size.width - 30.0 - 20.0, 60.0)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor colorWithWhite:51 / 255.0 alpha:1.0];
        [view addSubview:label];
        _operationMessageLabel = label;
    }
    return _operationMessageLabel;
}

#pragma mark - Action
///选择图片流程进行模拟
- (void)action {
    ZLPhotosSelectViewController *photosSelectVc = [ZLPhotosSelectViewController new];
    photosSelectVc.modalPresentationStyle = NO;
    [self presentViewController:photosSelectVc animated:YES completion:nil];

    //记忆上次选中的图片
    photosSelectVc.lastSelectedPhotos = self.images;

    //实现事件
    __weak typeof(self)weakSelf = self;
    __weak typeof(photosSelectVc)weakVc = photosSelectVc;
    photosSelectVc.leftItemAction = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };

    photosSelectVc.didSelectedPhotos = ^(NSArray<ZLPhotosSelectUnitModel *> * _Nonnull images) {
        
        //保存选择后的图片信息
        weakSelf.images = images;
        
        //如果你的页面需要展示选择后的图片，则可以通过索引找到对应模型，图片通过模型中的filePath属性加载
        
        [self debugShowTopMessage];
        
        //开启进度条
        [ZLOperationProgressBar show:weakSelf.view TopInset:10];
        
        //图片根据forIndex进行取出，然后经过一番操作，在发送至后台之后，调用next进行操作下一个图片，当图片操作完成，会调用结果
        [ZLOperationManager timeConsumingTasks:^(NSInteger forIndex, ZLOperationBlock  _Nullable nextTask) {
            ZLPhotosSelectUnitModel *unitModel = images[forIndex];
            [weakSelf debugShowOperationMessage:[NSString stringWithFormat:@"索引%ld：进行获取高清图",forIndex]];
            //获取高清图
            [unitModel getPhotosWithOriginal:YES Results:^(UIImage * _Nullable result) {
                [weakSelf debugShowOperationMessage:[NSString stringWithFormat:@"索引%ld：进行压缩高清图",forIndex]];
                //压缩高清图
                [ZLCompressionImageManager compressionImage:result Results:^(UIImage * _Nonnull compressionImage) {
                    [weakSelf debugShowOperationMessage:[NSString stringWithFormat:@"索引%ld：将压缩图保存至沙河",forIndex]];
                    //将压缩图保存至沙盒
                    [ZLPhotosSelectConfig.shared.sandboxManager writePhotosInSandboxWithIdentifier:unitModel.asset.localIdentifier Image:compressionImage Original:(ZLPhotosTypeCompression) Results:^(NSString * _Nonnull imgPath) {
                        [weakSelf debugShowOperationMessage:[NSString stringWithFormat:@"索引%ld：将压缩图上传至服务器",forIndex]];
                        //模型存储压缩图路径，方便上传后台服务器
                        unitModel.compressionFilePath = imgPath;
                        unitModel.compressionFileName = [imgPath componentsSeparatedByString:@"."].lastObject;
                        //模拟上传服务器耗时
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf debugShowOperationMessage:[NSString stringWithFormat:@"索引%ld：将压缩图上传至服务器成功\n",forIndex]];
                            
                            //更新进度条
                            ZLPhotosSelectConfig.shared.progressBar.progress = (forIndex + 1) / (images.count * 1.0);
                            
                            //执行下一个任务
                            nextTask();
                        });
                    }];
                }];
            }];
        } DependencyCount:images.count Result:^{
            [weakSelf debugShowDoneMessage];
        }];
        
        //关闭相册页面
        if (weakVc.leftItemAction) {
            weakVc.leftItemAction();
        }
    };
    
}
- (void)debugShowTopMessage {
    self.operationMessageLabel.text = nil;
    NSString *currentString = @"数据准备中\n";
    [self setOperationMessageLabelByAppendingText:currentString];
}
- (void)debugShowOperationMessage:(NSString *)message {
    [self setOperationMessageLabelByAppendingText:message];
}
- (void)debugShowDoneMessage {
    NSString *currentString = @"全部上传完成";
    [self setOperationMessageLabelByAppendingText:currentString];
}
- (void)setOperationMessageLabelByAppendingText:(NSString *)currentString {
    self.operationMessageLabel.text = !self.operationMessageLabel.text ? currentString : [NSString stringWithFormat:@"%@\n%@",self.operationMessageLabel.text,currentString];
    CGFloat height = [self.operationMessageLabel.text boundingRectWithSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 50.0, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]} context:nil].size.height;
    self.operationMessageLabel.frame = CGRectMake(self.operationMessageLabel.frame.origin.x, self.operationMessageLabel.frame.origin.y, self.operationMessageLabel.frame.size.width, height);
    self.operationMessageLabel.superview.frame = CGRectMake(self.operationMessageLabel.superview.frame.origin.x, self.operationMessageLabel.superview.frame.origin.y, self.operationMessageLabel.superview.frame.size.width, height + 20.0);
}

@end
