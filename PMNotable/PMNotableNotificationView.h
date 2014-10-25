//
//  PMNotableNotificationView.h
//  PMNotableDevelopment
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

#import "PMNotableNotificationViewDefinition.h"

@protocol PMNotableNotificationViewDelegate;

@interface PMNotableNotificationView : UIView <UIWebViewDelegate>

@property (weak, nonatomic) id<PMNotableNotificationViewDelegate> delegate;
@property (strong, nonatomic) PMNotableNotificationViewDefinition *viewDefinition;

- (instancetype)initWithViewDefinition:(PMNotableNotificationViewDefinition *)viewDefinition;

- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())completionBlock;
- (void)showAnimated:(BOOL)animated completionBlock:(void (^)())completionBlock;

@end

@protocol PMNotableNotificationViewDelegate <NSObject>

@optional
- (void)notificationViewShouldDismiss:(PMNotableNotificationView *)view;
- (void)notificationView:(PMNotableNotificationView *)view shouldDisplayViewWithID:(NSString *)viewID;
- (void)notificationView:(PMNotableNotificationView *)view shouldOpenURL:(NSURL *)url;

@end
