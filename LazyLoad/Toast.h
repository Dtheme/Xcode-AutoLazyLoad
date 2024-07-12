//
//  Toast.h
//  LazyLoad
//
//  Created by dzw on 2024/7/12.
//  Copyright © 2024 dzw. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define Toast(format, ...)  [Toast showWithMessage:[NSString stringWithFormat:format, ## __VA_ARGS__]]

NS_ASSUME_NONNULL_BEGIN
 
@interface Toast : NSObject

+ (void)showWithMessage:(NSString *)message;

@end


NS_ASSUME_NONNULL_END
