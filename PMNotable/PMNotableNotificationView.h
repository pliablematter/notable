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

@interface PMNotableNotificationView : UIView <UIWebViewDelegate>

@property (strong, nonatomic) PMNotableNotificationViewDefinition *viewDefinition;

- (instancetype)initWithViewDefinition:(PMNotableNotificationViewDefinition *)viewDefinition;

- (void)hideAnimated:(BOOL)animated;
- (void)showAnimated:(BOOL)animated;

@end
