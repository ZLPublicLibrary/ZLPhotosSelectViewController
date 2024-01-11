//
//  ZLOperationManager.m
//  ZLOperationManager_Example
//
//  Created by 赵磊 on 2020/6/8.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

#import "ZLOperationManager.h"

@implementation ZLOperationManager

static NSInteger forIndex = 0;

/**将耗时任务安排在队列中机型
 * 这样做是为了避免内存在大文件上传时导致撑爆
 * tasks 要做的事情  在该block内，会被调用参数count次（多次调用）
 * count 递归调用次数
 * results 完成后处理下文   
 */
+ (void)timeConsumingTasks:(ZLRecursiveBlock)tasks DependencyCount:(NSInteger)count Result:(ZLOperationBlock)results {
    if (!count) {
        return;
    }
    forIndex = 0;
    [self timeConsumingPrivateTasks:tasks DependencyCount:count Result:results];
}

+ (void)timeConsumingPrivateTasks:(ZLRecursiveBlock)tasks DependencyCount:(NSInteger)count Result:(ZLOperationBlock)results {
    if (forIndex == count) {
        results();
        forIndex = 0;
    }else {
        tasks(forIndex, ^{
            forIndex = forIndex + 1;
            [self timeConsumingPrivateTasks:tasks DependencyCount:count Result:results];
        });
    }
}

@end
