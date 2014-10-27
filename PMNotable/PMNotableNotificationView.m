//
//  PMNotableNotificationView.m
//  PMNotableDevelopment
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotableNotificationView.h"

@interface PMNotableNotificationView ()
{
    UIWebView *_webView;
}

@end

@implementation PMNotableNotificationView

#pragma mark - Init

- (instancetype)initWithViewDefinition:(PMNotableNotificationViewDefinition *)viewDefinition
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.viewDefinition = viewDefinition;
        
        CGFloat originY = self.viewDefinition.origin == PMViewOriginBottom ? [UIScreen mainScreen].bounds.size.height : -self.viewDefinition.height;
        self.frame = CGRectMake(0.0, originY, [UIScreen mainScreen].bounds.size.width, self.viewDefinition.height);
        
        _webView = [UIWebView new];
        _webView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.viewDefinition.file]]];
        [self addSubview:_webView];
        
        JSContext *context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        [context evaluateScript:[NSString stringWithFormat:@"function width(){return %f;}", self.frame.size.width]];
        [context evaluateScript:[NSString stringWithFormat:@"function height(){return %f;}", self.frame.size.height]];
    }
    return self;
}

#pragma mark - Public

- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())completionBlock
{
    [UIView animateWithDuration:animated ? 0.5 : 0.0 animations:^
    {
        CGRect frame = self.frame;
        frame.origin.y = self.viewDefinition.origin == PMViewOriginBottom ? [UIScreen mainScreen].bounds.size.height : -self.frame.size.height;
        self.frame = frame;
    }
    completion:^(BOOL finished)
    {
        if (completionBlock)
        {
            completionBlock();
        }
    }];
}

- (void)showAnimated:(BOOL)animated completionBlock:(void (^)())completionBlock
{
    [UIView animateWithDuration:animated ? 0.5 : 0.0 animations:^
    {
        CGRect frame = self.frame;
        frame.origin.y = self.viewDefinition.origin == PMViewOriginBottom ? [UIScreen mainScreen].bounds.size.height - self.frame.size.height : 0.0;
        self.frame = frame;
    }
    completion:^(BOOL finished)
    {
        if (completionBlock)
        {
            completionBlock();
        }
    }];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _webView.frame = self.bounds;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showAnimated:YES completionBlock:nil];
    
    JSContext *context =  [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context[@"dismiss"] = ^
    {
        if (_delegate && [_delegate respondsToSelector:@selector(notificationViewShouldDismiss:)])
        {
            [_delegate notificationViewShouldDismiss:self];
        }
    };
    
    context[@"display"] = ^(NSString *viewID)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(notificationView:shouldDisplayViewWithID:)])
        {
            [_delegate notificationView:self shouldDisplayViewWithID:viewID];
        }
    };
    
    context[@"setFlag"] = ^(NSString *flag, NSString *value)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(notificationView:shouldSetFlag:value:)])
        {
            [_delegate notificationView:self shouldSetFlag:flag value:value];
        }
    };
    
    context[@"openUrl"] = ^(NSString *urlString)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(notificationView:shouldOpenURL:)])
        {
            [_delegate notificationView:self shouldOpenURL:[NSURL URLWithString:urlString]];
        }
    };
}

@end
