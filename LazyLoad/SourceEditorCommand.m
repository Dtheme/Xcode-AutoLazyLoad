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

@interface SourceEditorCommand ()


@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    //EnumLazySwitch
    //propertyLazyLoad
    NSString *identifier = invocation.commandIdentifier;
    if ([identifier hasSuffix:kPropertyLazyLoad]) {
        [PropertyLazyLoad lazyLoadWithInvocation:invocation];
    }else if ([identifier hasSuffix:kEnumLazySwitch]) {
        [EnumLazySwitch enum2Switch:invocation];
    }
    completionHandler(nil);
}





@end
