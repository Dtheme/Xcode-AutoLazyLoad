//
//  SourceEditorCommand.m
//  LazyLoad
//
//  Created by dzw on 2017/9/8.
//  Copyright © 2017年 段志巍. All rights reserved.
//

#import "SourceEditorCommand.h"
typedef NS_ENUM(NSInteger, AdaptLanguageTarget) {
    AdaptLanguageTargetObjc,
    AdaptLanguageTargetSwift,
    AdaptLanguageTargetOther
}; 

@interface SourceEditorCommand ()

@property (nonatomic, strong)XCSourceEditorCommandInvocation *invocation;

@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{

//    NSLog(@"跑一个看看");
    self.invocation = invocation;
//    NSLog(@"%@",invocation.buffer.lines);
    for (XCSourceTextRange *range in self.invocation.buffer.selections) {
        NSInteger startLine = range.start.line;
        NSInteger endLine   = range.end.line;
        NSMutableArray<NSString *> * selectLines = [self selectLinesWithStart:startLine endLine:endLine invocation:self.invocation];
        for (int i = 0 ; i < selectLines.count ; i++) {
            NSString * string = selectLines[i];
            //排除空字符串
            if(string == nil||[string isEqualToString:@""]){
                continue;
            }
            AdaptLanguageTarget target = [self typeJudgeWithString:string];
            if (target == AdaptLanguageTargetOther) {
//                NSLog(@"不知道目标语言是什么");
                continue;
            }
            NSString * getterResult =@"";
            //objc
            if (target == AdaptLanguageTargetObjc) {
//                NSLog(@"目标语言是OC");
                getterResult = [self createObjcGetter:string];
                NSInteger implementationEndLine = [self findEndLine:self.invocation.buffer.lines selectionEndLine:endLine];
                if (implementationEndLine <= 1) {
                    continue;
                }
                [self.invocation.buffer.lines insertObject:getterResult atIndex:implementationEndLine];
            }else{
//                NSLog(@"目标语言是Swift");
                //swift
                getterResult = [self createSwiftGetter:string];
                if (!getterResult || [getterResult isEqualToString:@""]) {
                    continue;
                }
                //找到行号 清除原来的东西 添加懒加载代码
                NSInteger currentLine = [self findEndLine:self.invocation.buffer.lines selectionEndLine:endLine];
                self.invocation.buffer.lines[currentLine] = @"";
                [self.invocation.buffer.lines insertObject:getterResult atIndex:currentLine];
            }
        }
    }
    completionHandler(nil);
}

- (NSMutableArray<NSString *> *)selectLinesWithStart:(NSInteger)startLine endLine:(NSInteger)endLine invocation:(XCSourceEditorCommandInvocation *)invocation{
    NSMutableArray * selectLines = [NSMutableArray arrayWithCapacity:endLine-startLine];
    for (NSInteger i = startLine; i<=endLine ; i++) {
        [selectLines addObject:invocation.buffer.lines[i]];
    }
    return selectLines;
}


//判断是什么语言
- (AdaptLanguageTarget)typeJudgeWithString:(NSString *)string{
    
    if ([self targetString:string isContainString:@"@property"]) {
//        NSLog(@"1 oc");
        return AdaptLanguageTargetObjc;
    }
    if([self targetString:string isContainString:@"var "]){
//        NSLog(@"2 swift");
        return AdaptLanguageTargetSwift;
    }
    return AdaptLanguageTargetOther;
}

#pragma mark - 写objcGetter
- (NSString*)createObjcGetter:(NSString*)sourceStr{
    NSString *resultStr;
    NSString *className = [self targetString:sourceStr getStringWithOutSpaceBetweenString1:@")" string2:@"*"];
    if ([className isEqualToString:@""]) {
        return @"";
    }

    NSString *propertyName =[self targetString:sourceStr getStringWithOutSpaceBetweenString1:@"*" string2:@";"];
    if ([propertyName isEqualToString:@""]) {
        return @"";
    }

    //成员变量带下划线
    NSString *instancePName=[NSString stringWithFormat:@"_%@",propertyName];

    NSString *line1 = [NSString stringWithFormat:@"\n- (%@ *)%@{",className,propertyName];
    NSString *line2 = [NSString stringWithFormat:@"\n    if(!%@){",instancePName];
    NSString *line3 = [NSString stringWithFormat:@"\n        %@ = [[%@ alloc]init];",instancePName,className];
    NSString *line4 = [NSString stringWithFormat:@"\n    }"];
    NSString *line5 = [NSString stringWithFormat:@"\n    return %@;",instancePName];
    NSString *line6 = [NSString stringWithFormat:@"\n}"];
    
    resultStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",line1,line2,line3,line4,line5,line6];
    
    return resultStr;
}

- (NSString *)createSwiftGetter:(NSString*)sourceStr{
    NSString *resultStr = @"";
    //取类名 有等号或者有option
    NSString * className = @"";
    NSString * typeName = @"";
    if ([self targetString:sourceStr isContainString:@"="] && [self targetString:sourceStr isContainString:@")"]) {
        className = [self targetString:sourceStr getStringWithOutSpaceBetweenString1:@"=" string2:@"("];
        if ([self targetString:sourceStr isContainString:@":"]) {
            typeName = [self targetString:sourceStr getStringWithOutSpaceBetweenString1:@"var" string2:@":"];
        }else{

            typeName = [self targetString:sourceStr getStringWithOutSpaceBetweenString1:@"var" string2:@"="];
        }
    }else if ([self targetString:sourceStr isContainString:@":"] &&[self targetString:sourceStr isContainString:@"!"]){
        className =[self targetString:sourceStr getStringWithOutSpaceBetweenString1:@":" string2:@"!"];
        typeName =[self targetString:sourceStr getStringWithOutSpaceBetweenString1:@"var" string2:@":"];
    }else{
        return nil;
    }
    if ([className isEqualToString:@""]) {
        return nil;
    }
    if ([typeName isEqualToString:@""]) {
        return nil;
    }
    // 带块语法的lazy load
    NSString * line1 = [NSString stringWithFormat:@"\tlazy var %@ : %@ = {", typeName, className];
    NSString * line2 = [NSString stringWithFormat:@"\n\t\tlet object = %@()",className];
    NSString * line3 = [NSString stringWithFormat:@"\n\t\treturn object"];
    NSString * line4 = [NSString stringWithFormat:@"\n\t}()"];
    resultStr = [NSString stringWithFormat:@"%@%@%@%@",line1,line2,line3,line4];
    return resultStr;
}

//字符串操作
- (BOOL)targetString:(NSString *)string isContainString:(NSString *)subString {
    return [string rangeOfString:subString].location != NSNotFound? YES: NO;
}

- (NSString *)targetString:(NSString *)string getStringWithOutSpaceBetweenString1:(NSString *)string1 string2:(NSString *)string2{
    NSRange range=[string rangeOfString:string1];
    if(range.location==NSNotFound){
//        NSLog(@"错误的格式或者对象");
        return @"";
    }
    NSString * tempString = [string substringFromIndex:(range.location + range.length)];
    range = [tempString rangeOfString:string2];
    if(range.location==NSNotFound){
//        NSLog(@"错误的格式或者对象");
        return @"";
    }
    tempString = [tempString substringToIndex:range.location];
    NSString * typeName = [tempString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return typeName;
}

//行操作
- (NSInteger)findEndLine:(NSArray<NSString *> *)lines selectionEndLine:(NSInteger)endLine{
    //找interface确认类名
    NSString * interfaceLine = @"";
    for (NSInteger i = endLine; i >= 1; i--) {
        if ([lines[i] rangeOfString:@"@interface"].location != NSNotFound) {
            interfaceLine = lines[i];
            break;
        }
    }
    NSRange interfaceRange = [interfaceLine rangeOfString:@"@interface"];
    NSRange LeftRange = [interfaceLine rangeOfString:@"("];
    NSRange classWithSpaceRange = NSMakeRange(interfaceRange.location + interfaceRange.length, interfaceLine.length - interfaceRange.length - interfaceRange.location - (interfaceLine.length - LeftRange.location));
    NSString * removeSpace = [interfaceLine substringWithRange:classWithSpaceRange];
//    NSLog(@"%@",removeSpace);
    NSString * classStr = [removeSpace stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL kHasfindLine = NO;
    for (NSInteger i = endLine; i < lines.count; i++) {
        if ([lines[i] rangeOfString:@"@implementation"].location != NSNotFound &&
            [lines[i] rangeOfString:classStr].location != NSNotFound) {
            kHasfindLine = YES;
            continue;
        }
        if (kHasfindLine && [lines[i] rangeOfString:@"@end"].location != NSNotFound) {
            return i;
        }
    }
    return 0;
}


@end
