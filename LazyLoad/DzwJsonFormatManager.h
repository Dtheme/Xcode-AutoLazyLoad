//
//  DzwJsonFormatManager.h
//  LazyLoad
//
//  Created by dzw on 20/11/28.
//  Copyright (c) 2020年 dzw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DzwClassInfo;
@interface DzwJsonFormatManager : NSObject

/**
 *  解析一个类里面属性字段的内容
 *
 *  @param classInfo 类信息
 *
 *  atreturn 
 */
+ (NSString *)parsePropertyContentWithClassInfo:(DzwClassInfo *)classInfo;

/**
 *  解析一个类头文件的内容(会根据是否创建文件返回的内容有所不同)
 *
 *  @param classInfo 类信息
 *
 *  @return 类头文件里面的内容
 */
+ (NSString *)parseClassHeaderContentWithClassInfo:(DzwClassInfo *)classInfo;

@end
