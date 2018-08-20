//
//  PMNotable.m
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotable.h"

#import "PMNotableDownloader.h"
#import "PMNotableNotification.h"
#import "PMNotableNotificationView.h"

@interface PMNotable () <PMNotableNotificationViewDelegate>

@end

@implementation PMNotable

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Update

- (void)updateWithControlFile:(NSString *)controlFile
{
    PMNotableDownloader *downloader = [PMNotableDownloader new];
    
    [downloader requestControlFile:controlFile successBlock:^(id controlJSON)
    {
        [self parseControlJSON:controlJSON];
    }
    errorBlock:^(NSError *error)
    {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Notifications

- (PMNotableNotification *)notificationWithID:(NSString *)notificationID
{
    for (PMNotableNotification *notification in _notifications)
    {
        if ([notification.notificationID isEqualToString:notificationID])
        {
            return notification;
        }
    }
    
    return nil;
}

- (void)parseControlJSON:(id)controlJSON
{
    _notifications = nil;
    _notifications = [NSMutableArray new];
    
    PMNotableNotificationView *view = nil;
    
    for (NSString *key in [controlJSON allKeys])
    {
        PMNotableNotification *notification = [PMNotableNotification new];
        notification.notificationID = key;
        [notification parseJSONObject:[controlJSON objectForKey:key]];
        [_notifications addObject:notification];
        
        // Update launches count for each notification to track number of launches after displaying notification
        NSString *lastDisplayMinimumLaunchesKey = [NSString stringWithFormat:@"%@-%@-%d", PM_CONDITION_KEY, key, PMConditionTypeLastDisplayMinimumLaunches];
        NSInteger lastDisplayMinimumLaunches = [[NSUserDefaults standardUserDefaults] integerForKey:lastDisplayMinimumLaunchesKey];
        [[NSUserDefaults standardUserDefaults] setInteger:++lastDisplayMinimumLaunches forKey:lastDisplayMinimumLaunchesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([notification conditionsSatisfied] && !view)
        {
            PMNotableNotificationViewDefinition *viewDefinition = [notification viewDefinitionWithID:notification.entry];
            
            if (viewDefinition)
            {
                NSLog(@"showing '%@'", notification.notificationID);
                [notification updateUserDefaults];
                
                view = [[PMNotableNotificationView alloc] initWithViewDefinition:viewDefinition];
                view.delegate = self;
            }
        }
        else
        {
            NSLog(@"not showing '%@'", notification.notificationID);
        }
    }
    
    if (view)
    {
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

#pragma mark - PMNotableNotificationViewDelegate

- (void)notificationViewShouldDismiss:(PMNotableNotificationView *)view
{
    [view hideAnimated:YES completionBlock:^
    {
        [view removeFromSuperview];
    }];
}

- (void)notificationView:(PMNotableNotificationView *)view shouldDisplayViewWithID:(NSString *)viewID
{
    PMNotableNotification *notification = [self notificationWithID:view.viewDefinition.notificationID];
    PMNotableNotificationViewDefinition *viewDefinition = [notification viewDefinitionWithID:viewID];
    
    PMNotableNotificationView *newView = [[PMNotableNotificationView alloc] initWithViewDefinition:viewDefinition];
    newView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:newView];
}

- (void)notificationView:(PMNotableNotificationView *)view shouldSetFlag:(NSString *)flag value:(NSString *)value
{
    PMNotableNotification *notification = [self notificationWithID:view.viewDefinition.notificationID];
    
    NSString *flagNotSetKey = [NSString stringWithFormat:@"%@-%@-%d-%@", PM_CONDITION_KEY, notification.notificationID, PMConditionTypeFlagNotSet, flag];
    [[NSUserDefaults standardUserDefaults] setBool:[value boolValue] forKey:flagNotSetKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)notificationView:(PMNotableNotificationView *)view shouldOpenURL:(NSURL *)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
