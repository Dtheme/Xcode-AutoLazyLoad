//
//  EnumLazySwitch.h
//  LazyLoad
//
//  Created by dzw on 2019/12/24.
//  Copyright © 2019 dzw. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

extern NSString * _Nonnull const kEnumLazySwitch;

NS_ASSUME_NONNULL_BEGIN

@interface EnumLazySwitch : NSObject

+ (void)enum2Switch:(XCSourceEditorCommandInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
