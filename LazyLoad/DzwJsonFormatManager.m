//
//  DzwJsonFormatManager.m
//  LazyLoad
//
//  Created by dzw on 20/11/28.
//  Copyright (c) 2020年 dzw. All rights reserved.
//

#import "DzwJsonFormatManager.h"
#import "DzwClassInfo.h"
#import <AppKit/AppKit.h>

#define ESUppercaseKeyWords @[@"id"]

@interface DzwJsonFormatManager()

@end
@implementation DzwJsonFormatManager

+ (NSString *)parsePropertyContentWithClassInfo:(DzwClassInfo *)classInfo{
    NSMutableString *resultStr = [NSMutableString string];
    NSDictionary *dic = classInfo.classDic;
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, NSObject *obj, BOOL *stop) {
        if (classInfo.isSwift) {
            [resultStr appendFormat:@"%@\n",[self formatSwiftWithKey:key value:obj classInfo:classInfo]];
        }else{
            [resultStr appendFormat:@"%@\n",[self formatObjcWithKey:key value:obj classInfo:classInfo]];
        }
    }];
    return resultStr;
}

/**
 *  格式化OC属性字符串
 *
 *  @param key       JSON里面key字段
 *  @param value     JSON里面key对应的NSDiction或者NSArray
 *  @param classInfo 类信息
 *
 *  atreturn
 */
+ (NSString *)formatObjcWithKey:(NSString *)key value:(NSObject *)value classInfo:(DzwClassInfo *)classInfo{
    NSString *qualifierStr = @"copy";
    NSString *typeStr = @"NSString";
    //判断大小写
    if ([ESUppercaseKeyWords containsObject:key] /*&& [ESJsonFormatSetting defaultSetting].uppercaseKeyWordForId*/) {
        key = [key uppercaseString];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[@(YES) class]]){
        //the 'NSCFBoolean' is private subclass of 'NSNumber'
        qualifierStr = @"assign";
        typeStr = @"BOOL";
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[NSNumber class]]){
        qualifierStr = @"assign";
        NSString *valueStr = [NSString stringWithFormat:@"%@",value];
        if ([valueStr rangeOfString:@"."].location!=NSNotFound){
            typeStr = @"CGFloat";
        }else{
            NSNumber *valueNumber = (NSNumber *)value;
            if ([valueNumber longValue]<2147483648) {
                typeStr = @"NSInteger";
            }else{
                typeStr = @"long long";
            }
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ %@;",qualifierStr,typeStr,key];
    }else if([value isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray *)value;
        
        //May be 'NSString'，will crash
        NSString *genericTypeStr = @"";
        NSObject *firstObj = [array firstObject];
        if ([firstObj isKindOfClass:[NSDictionary class]]) {
            DzwClassInfo *childInfo = classInfo.propertyArrayDic[key];
            genericTypeStr = [NSString stringWithFormat:@"<%@ *>",childInfo.className];
        }else if ([firstObj isKindOfClass:[NSString class]]){
            genericTypeStr = @"<NSString *>";
        }else if ([firstObj isKindOfClass:[NSNumber class]]){
            genericTypeStr = @"<NSNumber *>";
        }
        
        qualifierStr = @"strong";
        typeStr = @"NSArray";
//        if ([ESJsonFormatSetting defaultSetting].useGeneric && [ESUtils isXcode7AndLater]) {
            return [NSString stringWithFormat:@"@property (nonatomic, %@) %@%@ *%@;",qualifierStr,typeStr,genericTypeStr,key];
//        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }else if ([value isKindOfClass:[NSDictionary class]]){
        qualifierStr = @"strong";
        DzwClassInfo *childInfo = classInfo.propertyClassDic[key];
        typeStr = childInfo.className;
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
    }
    return [NSString stringWithFormat:@"@property (nonatomic, %@) %@ *%@;",qualifierStr,typeStr,key];
}


/**
 *  格式化Swift属性字符串
 *
 *  @param key       JSON里面key字段
 *  @param value     JSON里面key对应的NSDiction或者NSArray
 *  @param classInfo 类信息
 *
 *  atreturn
 */
+ (NSString *)formatSwiftWithKey:(NSString *)key value:(NSObject *)value classInfo:(DzwClassInfo *)classInfo{
    NSString *typeStr = @"String";
    //判断大小写
    if ([ESUppercaseKeyWords containsObject:key] /*&& [ESJsonFormatSetting defaultSetting].uppercaseKeyWordForId*/) {
        key = [key uppercaseString];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"    var %@: %@ = \"\"", key, typeStr];
    }else if([value isKindOfClass:[@(YES) class]]){
        typeStr = @"Bool";
        return [NSString stringWithFormat:@"    var %@: %@ = false", key, typeStr];
    }else if([value isKindOfClass:[NSNumber class]]){
        NSString *valueStr = [NSString stringWithFormat:@"%@", value];
        if ([valueStr rangeOfString:@"."].location!=NSNotFound){
            typeStr = @"Double";
        }else{
            typeStr = @"Int";
        }
        return [NSString stringWithFormat:@"    var %@: %@ = 0", key, typeStr];
    }else if([value isKindOfClass:[NSArray class]]){
        DzwClassInfo *childInfo = classInfo.propertyArrayDic[key];
        NSString *type = childInfo.className;
        return [NSString stringWithFormat:@"    var %@: [%@] = [%@]()", key, type?:@"String", type?:@"String"];
    }else if ([value isKindOfClass:[NSDictionary class]]){
        DzwClassInfo *childInfo = classInfo.propertyClassDic[key];
        typeStr = childInfo.className;
        if (!typeStr) {
            typeStr = [key capitalizedString];
        }
        return [NSString stringWithFormat:@"    var %@: %@ = %@()", key, typeStr, typeStr];
    }
    return [NSString stringWithFormat:@"    var %@: %@ = \"\"", key, typeStr];
}

+ (NSString *)parseClassHeaderContentWithClassInfo:(DzwClassInfo *)classInfo{
    if (classInfo.isSwift) {
        return [self parseClassContentForSwiftWithClassInfo:classInfo];
    }else{
        return [self parseClassHeaderContentForOjbcWithClassInfo:classInfo];
    }
}

/**
 *  解析.h文件内容--Objc
 *
 *  @param classInfo 类信息
 *
 *  atreturn
 */
+ (NSString *)parseClassHeaderContentForOjbcWithClassInfo:(DzwClassInfo *)classInfo{
    NSMutableString *result = [NSMutableString stringWithFormat:@"@interface %@ : NSObject\n\n",classInfo.className];
    [result appendString:classInfo.propertyContent];
    [result appendString:@"\n@end"];
    return [result copy];
}

/**
 *  解析.swift文件内容--Swift
 *
 *  @param classInfo 类信息
 *
 *  atreturn
 */
+ (NSString *)parseClassContentForSwiftWithClassInfo:(DzwClassInfo *)classInfo{
    
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathes.firstObject stringByAppendingPathComponent:@"SuperClass.txt"];
    NSString *superClass = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (superClass.length == 0) {
        superClass = @"NSObject";
    }
    
    NSMutableString *result = [NSMutableString stringWithFormat:@"class %@: %@ {\n\n",classInfo.className, superClass];
    [result appendString:classInfo.propertyContent];
    [result appendString:@"\n}"];
    return [result copy];
}


@end
