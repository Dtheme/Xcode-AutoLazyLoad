//
//  JsonLazyProperty.h
//  LazyLoad
//
//  Created by dzw on 2022/1/11.
//  Copyright © 2022 dzw. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

extern NSString * _Nonnull const kJsonLazyProperty;

NS_ASSUME_NONNULL_BEGIN

@interface JsonLazyProperty : NSObject
+ (void)JSON2Property:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler;

@end

NS_ASSUME_NONNULL_END
