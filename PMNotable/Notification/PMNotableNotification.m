//
//  PMNotableNotification.m
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotableNotification.h"

@implementation PMNotableNotification

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _notificationID = @"";
        _allConditions = [NSMutableArray new];
        _anyConditions = [NSMutableArray new];
        _entry = @"";
        _viewDefinitions = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Public

- (BOOL)conditionsSatisfied
{
    BOOL allSatisfied = YES;
    for (PMNotableNotificationCondition *condition in _allConditions)
    {
        if (![condition satisfied])
        {
            allSatisfied = NO;
            break;
        }
    }
    
    BOOL anySatisfied = _anyConditions.count == 0;
    for (PMNotableNotificationCondition *condition in _anyConditions)
    {
        if ([condition satisfied])
        {
            anySatisfied = YES;
            break;
        }
    }
    
    return allSatisfied && anySatisfied;
}

- (void)parseJSONObject:(id)JSONObject
{
    // Conditions
    if ([JSONObject objectForKey:@"conditions"])
    {
        NSDictionary *conditions = [JSONObject objectForKey:@"conditions"];
        
        // All
        if ([conditions objectForKey:@"all"])
        {
            NSDictionary *allConditions = [conditions objectForKey:@"all"];
            
            for (NSString *key in allConditions.allKeys)
            {
                PMNotableNotificationCondition *condition = [PMNotableNotificationCondition new];
                condition.key = key;
                condition.notificationID = _notificationID;
                condition.value = [allConditions objectForKey:key];
                [_allConditions addObject:condition];
            }
        }
        
        // Any
        if ([conditions objectForKey:@"any"])
        {
            NSDictionary *anyConditions = [conditions objectForKey:@"any"];
            
            for (NSString *key in anyConditions.allKeys)
            {
                PMNotableNotificationCondition *condition = [PMNotableNotificationCondition new];
                condition.key = key;
                condition.notificationID = _notificationID;
                condition.value = [anyConditions objectForKey:key];
                [_anyConditions addObject:condition];
            }
        }
    }
    
    // Entry
    if ([JSONObject objectForKey:@"entry"])
    {
        self.entry = [JSONObject objectForKey:@"entry"];
    }
    
    // Views
    if ([JSONObject objectForKey:@"views"])
    {
        NSDictionary *views = [JSONObject objectForKey:@"views"];
        
        for (NSString *key in views.allKeys)
        {
            PMNotableNotificationViewDefinition *viewDefinition = [PMNotableNotificationViewDefinition new];
            viewDefinition.notificationID = _notificationID;
            viewDefinition.viewID = key;
            [viewDefinition parseJSONObject:[views objectForKey:key]];
            [_viewDefinitions addObject:viewDefinition];
        }
    }
}

- (void)updateUserDefaults
{
    NSString *neverDisplayedKey = [NSString stringWithFormat:@"%@-%@-%d", PM_CONDITION_KEY, _notificationID, PMConditionTypeNeverDisplayed];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:neverDisplayedKey];
    
    NSString *lastDisplayMinimumSecondsKey = [NSString stringWithFormat:@"%@-%@-%d", PM_CONDITION_KEY, _notificationID, PMConditionTypeLastDisplayMinimumSeconds];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:lastDisplayMinimumSecondsKey];
    
    NSString *lastDisplayMinimumLaunchesKey = [NSString stringWithFormat:@"%@-%@-%d", PM_CONDITION_KEY, _notificationID, PMConditionTypeLastDisplayMinimumLaunches];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:lastDisplayMinimumLaunchesKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (PMNotableNotificationViewDefinition *)viewDefinitionWithID:(NSString *)viewID
{
    for (PMNotableNotificationViewDefinition *viewDefinition in _viewDefinitions)
    {
        if ([viewDefinition.viewID isEqualToString:viewID])
        {
            return viewDefinition;
        }
    }
    
    return nil;
}

#pragma mark - Memory management

- (void)dealloc
{
    _notificationID = nil;
    _allConditions = nil;
    _anyConditions = nil;
    _entry = nil;
    _viewDefinitions = nil;
}

@end
