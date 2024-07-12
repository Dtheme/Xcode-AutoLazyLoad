//
//  Toast.m
//  LazyLoad
//
//  Created by dzw on 2024/7/12.
//  Copyright © 2024 dzw. All rights reserved.
//
#import "Toast.h"

@implementation Toast

+ (void)showWithMessage:(NSString *)message {
    NSWindow *mainWindow = [NSApplication sharedApplication].mainWindow;
    if (!mainWindow) {
        return;
    }
    
    NSRect frame = NSMakeRect(mainWindow.frame.size.width / 2 - 150, mainWindow.frame.size.height - 100, 300, 50);
    NSWindow *toastWindow = [[NSWindow alloc] initWithContentRect:frame
                                                        styleMask:NSWindowStyleMaskBorderless
                                                          backing:NSBackingStoreBuffered
                                                            defer:NO];
    toastWindow.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.7];
    toastWindow.opaque = NO;
    toastWindow.hasShadow = YES;
    toastWindow.level = NSFloatingWindowLevel;
    
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 50)];
    [label setStringValue:message];
    [label setTextColor:[NSColor whiteColor]];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setBezeled:NO];
    [label setEditable:NO];
    [label setAlignment:NSTextAlignmentCenter];
    
    [toastWindow.contentView addSubview:label];
    [mainWindow addChildWindow:toastWindow ordered:NSWindowAbove];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toastWindow orderOut:nil];
        [mainWindow removeChildWindow:toastWindow];
    });
}

@end
