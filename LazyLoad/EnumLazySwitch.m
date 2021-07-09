//
//  EnumLazySwitch.m
//  LazyLoad
//
//  Created by dzw on 2019/12/24.
//  Copyright © 2019 dzw. All rights reserved.
//

#import "EnumLazySwitch.h"
#import <Cocoa/Cocoa.h>

NSString * _Nonnull const kEnumLazySwitch = @"EnumLazySwitch";
@implementation EnumLazySwitch

+ (void)enum2Switch:(XCSourceEditorCommandInvocation *)invocation{
    
    NSString *symbolString = @"";
    NSMutableString *selectString = [[NSMutableString alloc] init];
    NSInteger endLine = 0;
    //comments
    NSMutableArray *comments = [NSMutableArray array];
    for (XCSourceTextRange *range in invocation.buffer.selections) {
        NSInteger startLine = range.start.line;
        NSInteger startColumn = range.start.column;
        endLine = range.end.line;
        NSInteger endColumn = range.end.column;
        for (NSInteger index = startLine; index <= endLine ;index ++){
            NSString *line = invocation.buffer.lines[index];
            if (line == nil) {
                line = @" ";
            }
            if ([line containsString:@"//"]||[line containsString:@"/*"]) {
                NSArray *codeAnalysis;
                if ([line containsString:@"*/"]) {//注释使用的是 '/* */'
                    codeAnalysis = [line componentsSeparatedByString:@"/*"];
                }else if ([line containsString:@"///"]) {//注释使用的是 '///'
                    line = [line stringByReplacingOccurrencesOfString:@"///" withString:@"//"];
                    codeAnalysis = [line componentsSeparatedByString:@"//"];
                }else{//注释使用的是 '//'
                    codeAnalysis = [line componentsSeparatedByString:@"//"];
                }
                NSString *commentString = codeAnalysis.lastObject;
                if (codeAnalysis.count==2) {
                    [comments addObject:codeAnalysis.count>0?[[commentString stringByReplacingOccurrencesOfString:@"/*" withString:@""] stringByReplacingOccurrencesOfString:@"*/" withString:@""]:@""];
                    line = codeAnalysis.count>0?[codeAnalysis.firstObject stringByReplacingOccurrencesOfString:@" " withString:@""]:line;
                }else{
                    if ([commentString containsString:@"*/"]) {// 注释
                        [comments addObject:codeAnalysis.count>0?
                         [[[commentString stringByReplacingOccurrencesOfString:@"/*" withString:@""] stringByReplacingOccurrencesOfString:@"*/" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]:@""];
                        line = @"";
                    }else{ //代码
                        line = commentString;
                        [comments addObject:@""];
                    }
                }
            }
            if (index == endLine && line.length >= endColumn) {
                NSRange lineRange = NSMakeRange(0, endColumn);
                line = [line substringWithRange:lineRange];
            }
            
            if (index == startLine && line.length > startColumn) {
                NSRange lineRange = NSMakeRange(startColumn, line.length - startColumn);
                line = [line substringWithRange:lineRange];
            }
            
            [selectString appendString:line];
            if (endLine > startLine && index != endLine) {
                [selectString appendString:@"\n"];
            }
        }
    }
    symbolString = [selectString copy];
    
    NSString *finalStr = [self duelWithString:symbolString comments:comments];
    [self writePasteboardWithString:finalStr];
}

+ (NSString *)duelWithString:(NSString *)symbolString comments:(NSArray *)comments{
    
    if (([[symbolString lowercaseString] rangeOfString:@"enum "].length > 0) || [[symbolString lowercaseString] rangeOfString:@"ns_enum"].length > 0){
        
        BOOL isSwift = NO;
        if ([[symbolString lowercaseString] rangeOfString:@"    case "].length > 0){
            isSwift = YES;
        }
        symbolString = [[symbolString componentsSeparatedByString:@"::"] lastObject];
        
        symbolString = [symbolString stringByReplacingOccurrencesOfString:@"    case " withString:@""];
        
        symbolString = [symbolString stringByReplacingOccurrencesOfString:@"^enum\\s+" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, symbolString.length)];
        
        symbolString = [symbolString stringByReplacingOccurrencesOfString:@"^\\((.*)\\)$" withString:@"$1" options:NSRegularExpressionSearch range: NSMakeRange(0, symbolString.length)];
        
        symbolString = [symbolString stringByReplacingOccurrencesOfString:@"=.*?," withString:@"," options:NSRegularExpressionSearch range:NSMakeRange(0, symbolString.length)];
        
        symbolString = [symbolString stringByReplacingOccurrencesOfString:@"=.*?\n" withString:@"," options:NSRegularExpressionSearch range:NSMakeRange(0, symbolString.length)];
        
        if (isSwift) {
            symbolString = [symbolString stringByReplacingOccurrencesOfString:@"\n" withString:@"," options:NSRegularExpressionSearch range:NSMakeRange(0, symbolString.length)];
        }else{
            symbolString = [symbolString stringByReplacingOccurrencesOfString:@"\n" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, symbolString.length)];
        }
        
        NSRange range = [symbolString rangeOfString:@"\\{.*?\\}" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            symbolString = [symbolString substringWithRange:range];
        }
        symbolString = [symbolString stringByReplacingOccurrencesOfString:@"{" withString:@""];
        symbolString = [symbolString stringByReplacingOccurrencesOfString:@"}" withString:@""];
        
        NSArray *symbols = [symbolString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
        if (isSwift) {
            NSString *begin = @"\nswitch <#value#> {\n";
            NSString *end = @"    default:\n}\n";
            
            NSMutableString *stringFinal = [[NSMutableString alloc] init];
            for (NSUInteger index = 0;index < [symbols count];index ++) {
                NSString *sub = [symbols objectAtIndex:index];
                if (sub.length > 0) {
                    NSString *caseStr = [NSString stringWithFormat:@"    case .%@:\n<#code#>\n",sub];
                    [stringFinal appendString:caseStr];
                }
            }
            
            if (stringFinal.length > 0) {
                NSString *stringFinalF = [NSString stringWithFormat:@"%@%@%@",begin,stringFinal,end];
                NSLog(@"\n%@",stringFinalF);
                return stringFinalF;
            }
            
        }else{
            NSString *begin = @"\nswitch (<#EnumType#>) {\n";
            NSString *end = @"    default:\n        break;\n}\n";
            
            NSMutableString *stringFinal = [[NSMutableString alloc] init];
            for (NSUInteger index = 0;index < [symbols count];index ++) {
                //case
                NSString *sub = [symbols objectAtIndex:index];
                if (sub.length <= 0) {
                    continue;
                }
                sub = [[sub stringByReplacingOccurrencesOfString:@"    " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                //注释
                NSString *singleComment = comments[index];
                if (![singleComment isEqual:@""]) {//没有注释
                    singleComment = [NSString stringWithFormat:@"//%@",singleComment];
                }
                if (sub.length > 0) {
                    NSString *caseStr = [NSString stringWithFormat:@"    case %@:%@        <#statements#>\n        break;\n",sub,singleComment];
                    [stringFinal appendString:caseStr];
                }
            }
            
            if (stringFinal.length > 0) {
                NSString *stringFinalF = [NSString stringWithFormat:@"%@%@%@",begin,stringFinal,end];
                return stringFinalF;
            }
        }
    }
    return @"";
}

+ (void)writePasteboardWithString:(NSString *)aString{
    NSPasteboard *aPastenboard = [NSPasteboard generalPasteboard];
    [aPastenboard clearContents];
    NSData *aData = [aString dataUsingEncoding:NSUTF8StringEncoding];
    [aPastenboard setData:aData forType:NSPasteboardTypeString];
    
}
@end
