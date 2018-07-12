//
//  WJXFMDBHelper.h
//  EFCharger
//
//  Created by wangjixiao on 2018/7/12.
//  Copyright © 2018年 王吉笑. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>


@interface WJXFMDBHelper : NSObject


+ (instancetype)sharedClient;

/**
 创建表
 */
- (BOOL)creatTableWithTable:(NSString *)table;


/**
 删除表
 */
- (BOOL)deleteTableWithTable:(NSString *)table;

/**
 清除表数据
 */
- (BOOL)eraseTableWithTable:(NSString *)table;

/**
 添加数据
 */
- (BOOL)addModelWithTable:(NSString *)table
                    model:(NSObject *)model;
/**
 删除
 */
- (BOOL)deleteModelWithTable:(NSString *)table
                         key:(NSString *)key
                      values:(NSString *)values;
/**
 更新
 */
- (BOOL)updateModelWithTable:(NSString *)table
                         key:(NSString *)key
                   oldValues:(NSString *)oldValues
                      values:(NSString *)values;
/**
 查询所有
 */
- (NSArray *)selectAllModelWithTable:(NSString *)table;

/**
 查询
 */
- (NSArray *)selectModelWithTable:(NSString *)table
                              key:(NSString *)key
                           values:(NSString *)values;

@end
