//
//  SourceEditorCommand.m
//  LazyLoad
//
//  Created by dzw on 2017/9/8.
//  Copyright © 2017年 段志巍. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "EnumLazySwitch.h"
#import "PropertyLazyLoad.h"
#import "JsonLazyProperty.h"
#import <AppKit/AppKit.h>
#import "DzwClassInfo.h"
#import "JsonLazyProperty.h"

@interface SourceEditorCommand ()
@property (nonatomic) BOOL isSwift;
@property (nonatomic, strong) XCSourceTextBuffer *buffer;
@property (nonatomic, copy) void(^completionHandler)(NSError * _Nullable nilOrError);
@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSString *identifier = invocation.commandIdentifier;
    if ([identifier hasSuffix:kPropertyLazyLoad]) {
        [PropertyLazyLoad lazyLoadWithInvocation:invocation];
    }else if ([identifier hasSuffix:kEnumLazySwitch]) {
        [EnumLazySwitch enum2Switch:invocation];
    }else if ([identifier hasSuffix:kJsonLazyProperty]){
        [JsonLazyProperty JSON2Property:invocation completionHandler:completionHandler];
    }
    completionHandler(nil);
}



@end
