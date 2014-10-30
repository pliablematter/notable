//
//  PMNotableNotificationCondition.m
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotableNotificationCondition.h"

#import "Reachability.h"

// Version macros
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define APP_VERSION_LESS_THAN(v)    ([[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] compare:v options:NSNumericSearch] == NSOrderedAscending)

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
    NSString *defaultsKey = [NSString stringWithFormat:@"%@-%@-%d", PM_CONDITION_KEY, _notificationID, _type];
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
            satisfied = [[NSUserDefaults standardUserDefaults] boolForKey:defaultsKey] != [_value boolValue]; // Reversed logic because of negation in type
        }
            break;
        case PMConditionTypeLastDisplayMinimumSeconds:
        {
            NSDate *lastDisplayDate = [[NSUserDefaults standardUserDefaults] objectForKey:defaultsKey];
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:lastDisplayDate];
            satisfied = (NSInteger)timeInterval > [_value integerValue];
        }
            break;
        case PMConditionTypeLastDisplayMinimumLaunches:
        {
            NSInteger lastDisplayMinimumLaunches = [[NSUserDefaults standardUserDefaults] integerForKey:defaultsKey];
            satisfied = lastDisplayMinimumLaunches > [_value integerValue];
        }
            break;
        case PMConditionTypeFlagNotSet:
        {
            defaultsKey = [NSString stringWithFormat:@"%@-%@-%d-%@", PM_CONDITION_KEY, _notificationID, _type, _value];
            satisfied = ![[NSUserDefaults standardUserDefaults] boolForKey:defaultsKey];
        }
            break;
        case PMConditionTypeiOSVersionLessThan:
        {
            satisfied = SYSTEM_VERSION_LESS_THAN(_value);
        }
            break;
        case PMConditionTypeAppVersionLessThan:
        {
            satisfied = APP_VERSION_LESS_THAN(_value);
        }
            break;
        default:
            break;
    }
    
    NSLog(@"condition - %@: %@ -> %@", _key, _value, satisfied ? @"YES": @"NO");
    
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
    else if ([_key isEqualToString:@"lastDisplayMinimumSeconds"])
    {
        _type = PMConditionTypeLastDisplayMinimumSeconds;
    }
    else if ([_key isEqualToString:@"lastDisplayMinimumLaunches"])
    {
        _type = PMConditionTypeLastDisplayMinimumLaunches;
    }
    else if ([_key isEqualToString:@"flagNotSet"])
    {
        _type = PMConditionTypeFlagNotSet;
    }
    else if ([_key isEqualToString:@"iOSVersionLessThan"])
    {
        _type = PMConditionTypeiOSVersionLessThan;
    }
    else if ([_key isEqualToString:@"appVersionLessThan"])
    {
        _type = PMConditionTypeAppVersionLessThan;
    }
    else
    {
        NSLog(@"Warning: Unknown condition '%@' used", key);
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
