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
    }
    return self;
}

#pragma mark - Public

- (void)hideAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.5];
    }
    
    CGRect frame = self.frame;
    frame.origin.y = self.viewDefinition.origin == PMViewOriginBottom ? [UIScreen mainScreen].bounds.size.height : -self.frame.size.height;
    self.frame = frame;
    
    if (animated)
    {
        [UIView commitAnimations];
    }
}

- (void)showAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.5];
    }
    
    CGRect frame = self.frame;
    frame.origin.y = self.viewDefinition.origin == PMViewOriginBottom ? [UIScreen mainScreen].bounds.size.height - self.frame.size.height : 0.0;
    self.frame = frame;
    
    if (animated)
    {
        [UIView commitAnimations];
    }
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
    [self showAnimated:YES];
    
    JSContext *context =  [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"onclick"] = ^(JSValue *parameter)
    {
        [self buttonTapped:parameter];
    };
}

- (void)buttonTapped:(JSValue *)parameter
{
    NSLog(@"%@", parameter);
    [self hideAnimated:YES];
}

@end
