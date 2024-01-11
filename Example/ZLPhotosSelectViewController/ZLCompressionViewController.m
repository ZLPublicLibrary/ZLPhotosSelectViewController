//
//  ZLCompressionViewController.m
//  ZLPhotosSelectViewController_Example
//
//  Created by 赵磊 on 2020/6/10.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLCompressionViewController.h"
#import <ZLPhotosSelectHeader.h>

@interface ZLCompressionViewController ()

///图片组
@property (nonatomic,weak) UIImageView *imageBox;
///压缩
@property (nonatomic,weak) UIButton *compressionButton;
///压缩信息
@property (nonatomic,weak) UILabel *compressionMessageLabel;

@end

@implementation ZLCompressionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self compressionButton];
}

#pragma mark - Lazy
- (UIImageView *)imageBox {
    if (!_imageBox) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"testImage1" ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        CGFloat width = UIScreen.mainScreen.bounds.size.width - 30.0;
        CGFloat y = 40.0;
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, y, width, width)];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.clipsToBounds = YES;
        view.image = image;
        view.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width - 60.0, width - 30.0, 60, 30.0)];
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.textColor = UIColor.whiteColor;
        label.backgroundColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"压缩前";
        [view addSubview:label];
        
        [self.view addSubview:view];
        _imageBox = view;
    }
    return _imageBox;
}
- (UIButton *)compressionButton {
    if (!_compressionButton) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.imageBox.frame) + 30.0, UIScreen.mainScreen.bounds.size.width - 30.0, 45.0)];
        button.backgroundColor = UIColor.cyanColor;
        button.layer.borderWidth = 0.5;
        button.layer.borderColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.7].CGColor;
        button.layer.cornerRadius = CGRectGetHeight(button.frame) / 2;
        button.layer.masksToBounds = YES;
        [button setTitle:@"一键测试压缩图片功能" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [button addTarget:self action:@selector(compressionAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        _compressionButton = button;
    }
    return _compressionButton;
}
- (UILabel *)compressionMessageLabel {
    if (!_compressionMessageLabel) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0, CGRectGetMaxY(self.compressionButton.frame) + 30.0, UIScreen.mainScreen.bounds.size.width - 30.0, 80.0)];
        view.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
        view.hidden = YES;
        view.layer.cornerRadius = 3.0;
        view.layer.masksToBounds = YES;
        [self.view addSubview:view];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, UIScreen.mainScreen.bounds.size.width - 30.0 - 20.0, 60.0)];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:12.0];
        label.textColor = [UIColor colorWithWhite:51 / 255.0 alpha:1.0];
        [view addSubview:label];
        _compressionMessageLabel = label;
    }
    return _compressionMessageLabel;
}

#pragma mark - Action
- (void)compressionAction {
    
    NSString *path = [NSBundle.mainBundle pathForResource:@"testImage1" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    //压缩前
    [self compressionBefore:path];
    
    __weak typeof(self)weakSelf = self;
    [ZLCompressionImageManager compressionImage:image Results:^(UIImage * _Nonnull result) {
        
        //压缩后
        [weakSelf compressionAfter:result];
        
    }];
}
- (void)compressionBefore:(NSString *)path {
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    self.imageBox.image = image;
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *message = [NSString stringWithFormat:@"开始压缩\n压缩前：%.1fM   width:%.1f   height:%.1f",data.length / 1024 / 1024.0,self.imageBox.image.size.width,self.imageBox.image.size.height];
    NSLog(@"%@",message);
    self.compressionMessageLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:message attributes:nil];;
    self.compressionMessageLabel.superview.hidden = NO;
    self.compressionMessageLabel.frame = CGRectMake(self.compressionMessageLabel.frame.origin.x, self.compressionMessageLabel.frame.origin.y, self.compressionMessageLabel.frame.size.width, 29.0);
    UILabel *label = self.imageBox.subviews.firstObject;
    label.text = @"压缩前";
}
- (void)compressionAfter:(UIImage *)result {
    NSData *resultData = UIImageJPEGRepresentation(result, 0.5);
    NSString *lastMessage = [NSString stringWithFormat:@"压缩后：%.1fKB   width:%.1f   height:%.1f",resultData.length / 2 * 3 / 1024.0,result.size.width,result.size.height];
    NSLog(@"%@",lastMessage);
    lastMessage = [self.compressionMessageLabel.text stringByAppendingString:[NSString stringWithFormat:@"\n%@\n(实际大小以图片真实数据为准，已保存至相册)",lastMessage]];
    NSMutableAttributedString *attrM = [[NSMutableAttributedString alloc] initWithString:lastMessage];
    [attrM addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:NSMakeRange(attrM.string.length - 22, 22)];
    self.compressionMessageLabel.attributedText = attrM;
    self.compressionMessageLabel.frame = CGRectMake(self.compressionMessageLabel.frame.origin.x, self.compressionMessageLabel.frame.origin.y, self.compressionMessageLabel.frame.size.width, 60.0);
    self.imageBox.image = result;
    UILabel *label = self.imageBox.subviews.firstObject;
    label.text = @"压缩后";
    //保存至相册
    UIImageWriteToSavedPhotosAlbum(result, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
///保存图片后的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"为方便您调试，压缩图已保存至相册" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    defaultAction = [UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"photos-redirect://"]];
    }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
