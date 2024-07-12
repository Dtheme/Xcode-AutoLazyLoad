//
//  EnumLazyIfelse.h
//  LazyLoad
//
//  Created by dzw on 2024/7/12.
//  Copyright © 2024 dzw. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString * _Nonnull const kEnumLazyIfelse;
@interface EnumLazyIfelse : NSObject
+ (void)enum2ifelse:(XCSourceEditorCommandInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
