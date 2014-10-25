//
//  PMNotableNotificationCondition.m
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotableNotificationCondition.h"

#import "Reachability.h"

#define PM_CONDITION_KEY @"kPMConditionKey"

@implementation PMNotableNotificationCondition

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _key = @"";
        _notificationID = @"";
        _type = PMConditionTypeNone;
        _value = @"";
    }
    return self;
}

#pragma mark - Public

- (BOOL)satisfied
{
    BOOL satisfied = NO;
    
    switch (_type)
    {
        case PMConditionTypeOnWifi:
        {
            BOOL onWifi = [Reachability reachabilityForLocalWiFi].currentReachabilityStatus == ReachableViaWiFi;
            satisfied = onWifi == [_value boolValue];
        }
            break;
        case PMConditionTypeNeverDisplayed:
        {
            NSString *defaultsKey = [NSString stringWithFormat:@"%@-%@-%d", PM_CONDITION_KEY, _notificationID, _type];
            satisfied = [[NSUserDefaults standardUserDefaults] boolForKey:defaultsKey] != [_value boolValue];
        }
            break;
            
        default:
            break;
    }
    
    NSLog(@"%@: %@ -> %@", _key, _value, satisfied ? @"YES": @"NO");
    
    return satisfied;
}

- (void)setKey:(NSString *)key
{
    _key = nil;
    _key = key;
    
    if ([_key isEqualToString:@"onWifi"])
    {
        _type = PMConditionTypeOnWifi;
    }
    else if ([_key isEqualToString:@"neverDisplayed"])
    {
        _type = PMConditionTypeNeverDisplayed;
    }
    else if ([_key isEqualToString:@"lastDisplayedMinimumLaunches"])
    {
        _type = PMConditionTypeLastDisplayedMinimumLaunches;
    }
    else
    {
        _type = PMConditionTypeNone;
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    _key = nil;
    _notificationID = nil;
    _value = nil;
}

@end
