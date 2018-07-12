//
//  WJXFMDBHelper.m
//  EFCharger
//
//  Created by wangjixiao on 2018/7/12.
//  Copyright © 2018年 王吉笑. All rights reserved.
//

#import "WJXFMDBHelper.h"

#define modelClass @"WJXFMDBModelClass"

@interface WJXFMDBHelper ()

@property (nonatomic, strong) FMDatabase *database;

@end

@implementation WJXFMDBHelper

/**
 *  HTTP 单例
 */
+ (instancetype)sharedClient
{
    static WJXFMDBHelper *_helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[WJXFMDBHelper alloc] init];
    });
    return _helper;
}

- (NSString *)cacheDirectory
{
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //设置数据库名称
    NSString *fileName = [docPath stringByAppendingPathComponent:@"EFCharger.sqlite"];
    NSLog(@"%@", fileName);
    return fileName;
}


/**
 创建表
 */
- (BOOL)creatTableWithTable:(NSString *)table
{
    BOOL result = NO;
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ text);",table ,modelClass];
        result = [self.database executeUpdate:sql];
        [self.database close];
    }
    return result;
}



/**
 删除表
 */
- (BOOL)deleteTableWithTable:(NSString *)table
{
    BOOL result = NO;
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"DROP TABLE %@", table];
        result = [self.database executeUpdate:sql];
        [self.database close];
    }
    return result;
}


/**
 清除表数据
 */
- (BOOL)eraseTableWithTable:(NSString *)table
{
    BOOL result = NO;
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", table];
        result = [self.database executeUpdate:sql];
        [self.database close];
    }
    return result;
}


/**
 添加字段
 */
- (BOOL)addKeyWithTable:(NSString *)table
                    key:(NSString *)key
{
    BOOL result = NO;
    if ([self.database open]) {
        //判断字段是否存在
        if (![self.database columnExists:key inTableWithName:table]) {
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ text",table, key];
            result = [self.database executeUpdate:sql];
        }
        [self.database close];
    }
    return result;
}


/**
 添加数据
 */
- (BOOL)addModelWithTable:(NSString *)table
                    model:(NSObject *)model
{
    NSString *class = [self selectModelWithTable:table];
    BOOL result = NO;
    //判断数据库是不是已经有数据
    if (class.length > 0) {
        //有数据
        if ([NSStringFromClass([model class]) isEqualToString:class]) {
            result = [self insertModelWithTable:table
                                          model:model];
        }
    }  else {
        //无数据
        result = [self insertModelWithTable:table
                                      model:model];
        
    }
    return result;
}


/**
 添加模型到表中
 */
- (BOOL)insertModelWithTable:(NSString *)table
                       model:(NSObject *)model
{
    unsigned int outCount = 0;
    NSMutableArray *keyArray = [NSMutableArray arrayWithCapacity:1];
    objc_property_t *properties = class_copyPropertyList([model class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property)
                                                 encoding:NSUTF8StringEncoding];
        [keyArray addObject:key];
    }
    free(properties);
    properties = NULL;
    
    NSString *sqlKey = [NSString stringWithFormat:@"(%@", modelClass];
    NSString *sqlValues = [NSString stringWithFormat:@"('%@'", NSStringFromClass([model class])];
    NSInteger valuseCount = 0;
    for (int i = 0; i < keyArray.count; i++) {
        NSString *key = [keyArray objectAtIndex:i];
        if (![[key lowercaseString] isEqualToString:modelClass]) {
            [self addKeyWithTable:table
                              key:key];
        }
        id valuse = [model valueForKey:key];
        if (valuse) {
            sqlKey=  [sqlKey stringByAppendingString:[NSString stringWithFormat:@", %@", key]];
            sqlValues = [sqlValues stringByAppendingString:[NSString stringWithFormat:@", '%@'", valuse]];
            valuseCount++;
        }
    }
    BOOL result = NO;
    if (valuseCount > 0) {
        sqlKey = [sqlKey stringByAppendingString:@")"];
        sqlValues = [sqlValues stringByAppendingString:@")"];
        if ([self.database open]) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ %@ VALUES %@", table, sqlKey, sqlValues];
            result= [self.database executeUpdate:sql];
            [self.database close];
        }
    }
    return  result;
}

/**
 删除
 */
- (BOOL)deleteModelWithTable:(NSString *)table
                         key:(NSString *)key
                      values:(NSString *)values
{
    BOOL result = NO;
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@ = %@",table ,key, values];
        result = [self.database executeUpdate:sql];
        [self.database close];
    }
    return result;
}

/**
 更新
 
 */
- (BOOL)updateModelWithTable:(NSString *)table
                         key:(NSString *)key
                   oldValues:(NSString *)oldValues
                      values:(NSString *)values

{
    BOOL result = NO;
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = %@ where %@ = %@",table, key, values, key,oldValues];
        result = [self.database executeUpdate:sql];
        [self.database close];
    }
    return result;
}

/**
 查询所存储的Class
 */
- (NSString *)selectModelWithTable:(NSString *)table
{
    NSString *class = nil;
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", table];
        FMResultSet *resultSet = [self.database executeQuery:sql];
        // 2.遍历结果
        while ([resultSet next]) {
            class = [resultSet stringForColumn:modelClass];
            if (class.length > 0) {
                break;
            }
        }
        [self.database close];
    }
    return class;
}

/**
 查询所有
 */
- (NSArray *)selectAllModelWithTable:(NSString *)table
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@",table];
        FMResultSet *resultSet = [self.database executeQuery:sql];
        // 2.遍历结果
        while ([resultSet next]) {
            NSString *name = [resultSet stringForColumn:modelClass];
            NSObject *model = [[NSClassFromString(name) alloc]init];
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList([model class], &outCount);
            for (int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *key = [[NSString alloc] initWithCString:property_getName(property)
                                                         encoding:NSUTF8StringEncoding];
                [model setValue:[resultSet stringForColumn:key] forKey:key];
            }
            free(properties);
            properties = NULL;
            
            [array addObject:model];
        }
        [self.database close];
    }
    return [NSArray arrayWithArray:array];
}

/**
 查询具体数据
 */
- (NSArray *)selectModelWithTable:(NSString *)table
                              key:(NSString *)key
                           values:(NSString *)values
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    if ([self.database open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = %@",table, key, values];
        FMResultSet *resultSet = [self.database executeQuery:sql];
        // 2.遍历结果
        while ([resultSet next]) {
            NSString *name = [resultSet stringForColumn:modelClass];
            NSObject *model = [[NSClassFromString(name) alloc]init];
            unsigned int outCount = 0;
            objc_property_t *properties = class_copyPropertyList([model class], &outCount);
            for (int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *key = [[NSString alloc] initWithCString:property_getName(property)
                                                         encoding:NSUTF8StringEncoding];
                [model setValue:[resultSet stringForColumn:key] forKey:key];
            }
            free(properties);
            properties = NULL;
            
            [array addObject:model];
        }
        [self.database close];
    }
    return [NSArray arrayWithArray:array];
}


- (FMDatabase *)database
{
    if (!_database) {
        NSString *fileName = [self cacheDirectory];
        _database = [FMDatabase databaseWithPath:fileName];
    }
    return _database;
}



@end
