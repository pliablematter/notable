//
//  PMNotable.m
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotable.h"

#import "AppDelegate.h"
#import "PMNotableDownloader.h"
#import "PMNotableNotification.h"
#import "PMNotableNotificationView.h"

@interface PMNotable () <PMNotableNotificationViewDelegate>
{
    AppDelegate *_appDelegate;
}

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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _appDelegate = [UIApplication sharedApplication].delegate;
    }
    return self;
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
    
    for (NSString *key in [controlJSON allKeys])
    {
        PMNotableNotification *notification = [PMNotableNotification new];
        notification.notificationID = key;
        [notification parseJSONObject:[controlJSON objectForKey:key]];
        [_notifications addObject:notification];
        
        // Update launches count for each notification to track number of launches after displaying notification
        NSString *lastDisplayedMinimumLaunchesKey = [NSString stringWithFormat:@"%@-%@-%d", PM_CONDITION_KEY, key, PMConditionTypeLastDisplayedMinimumLaunches];
        NSInteger lastDisplayedMinimumLaunches = [[NSUserDefaults standardUserDefaults] integerForKey:lastDisplayedMinimumLaunchesKey];
        [[NSUserDefaults standardUserDefaults] setInteger:++lastDisplayedMinimumLaunches forKey:lastDisplayedMinimumLaunchesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([notification conditionsSatisfied])
        {
            PMNotableNotificationViewDefinition *viewDefinition = [notification viewDefinitionWithID:notification.entry];
            
            if (viewDefinition)
            {
                NSLog(@"showing '%@'", notification.notificationID);
                [notification updateUserDefaults];
                
                PMNotableNotificationView *view = [[PMNotableNotificationView alloc] initWithViewDefinition:viewDefinition];
                view.delegate = self;
                [_appDelegate.window addSubview:view];
                
                break;
            }
        }
        else
        {
            NSLog(@"not showing '%@'", notification.notificationID);
        }
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
    [_appDelegate.window addSubview:newView];
}

- (void)notificationView:(PMNotableNotificationView *)view shouldOpenURL:(NSURL *)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
