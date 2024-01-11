//
//  ZLViewController.m
//  ZLPhotosSelectViewController
//
//  Created by itzhaolei@foxmail.com on 06/04/2020.
//  Copyright (c) 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLViewController.h"
#import "ZLAlbumViewController.h"
#import "ZLCompressionViewController.h"
#import "ZLOperationQueueViewController.h"
#import "ZLSimulationUseViewController.h"
#import "ZLTailorImageViewController.h"

@interface ZLViewController ()<UITableViewDataSource,UITableViewDelegate>

///资源
@property (nonatomic,strong) NSArray *resources;

@end

@implementation ZLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    ZLADAPTER_IOS11;
    ZLSHOWVERSION;
}

#pragma mark - Lazy
- (NSArray *)resources {
    if (!_resources) {
        _resources = ZLGETRESOURCES;
    }
    return _resources;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resources.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        cell.backgroundColor = UIColor.clearColor;
        cell.selectionStyle = NO;
        cell.textLabel.textColor = UIColor.whiteColor;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
        cell.detailTextLabel.textColor = cell.textLabel.textColor;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    }
    NSDictionary *dict = self.resources[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"remark"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.resources[indexPath.row];
    NSInteger type = [dict[@"id"] integerValue];
    if (type == 1) {
        [self presentViewController:[ZLAlbumViewController new] animated:YES completion:nil];
        return;
    }
    if (type == 2) {
        [self presentViewController:[ZLCompressionViewController new] animated:YES completion:nil];
        return;
    }
    if (type == 3) {
        [self presentViewController:[ZLOperationQueueViewController new] animated:YES completion:nil];
        return;
    }
    if (type == 4) {
        [self presentViewController:[ZLSimulationUseViewController new] animated:YES completion:nil];
        return;
    }
    if (type == 5) {
        [self presentViewController:[ZLSimulationUseViewController new] animated:YES completion:nil];
        return;
    }
}

@end
