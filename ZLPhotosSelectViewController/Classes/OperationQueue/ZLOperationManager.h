//
//  ZLOperationManager.h
//  ZLOperationManager_Example
//
//  Created by 赵磊 on 2020/6/8.
//  Copyright © 2020 itzhaolei@foxmail.com. All rights reserved.
//

typedef void(^ZLOperationBlock)(void);
typedef void(^ZLRecursiveBlock)(NSInteger forIndex, ZLOperationBlock _Nullable nextTask);

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZLOperationManager : NSObject

/**将耗时任务安排在队列中机型
 * 这样做是为了避免内存在大文件上传时导致撑爆
 * tasks 要做的事情  在该block内，会被调用参数count次（多次调用）
 * count 递归调用次数
 * results 完成后处理下文
 */
+ (void)timeConsumingTasks:(ZLRecursiveBlock)tasks DependencyCount:(NSInteger)count Result:(ZLOperationBlock)results;

@end

NS_ASSUME_NONNULL_END
