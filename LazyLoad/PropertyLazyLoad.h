//
//  LazyLoad.h
//  LazyLoad
//
//  Created by dzw on 2019/12/24.
//  Copyright © 2019 dzw. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

extern NSString * _Nonnull const kPropertyLazyLoad;

NS_ASSUME_NONNULL_BEGIN

@interface PropertyLazyLoad : NSObject

+ (void)lazyLoadWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

@end

NS_ASSUME_NONNULL_END
