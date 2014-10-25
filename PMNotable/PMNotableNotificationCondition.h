//
//  PMNotableNotificationCondition.h
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PMConditionType)
{
    PMConditionTypeNone,
    PMConditionTypeOnWifi,
    PMConditionTypeNeverDisplayed,
    PMConditionTypeLastDisplayedMinimumLaunches
};

@interface PMNotableNotificationCondition : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSString *notificationID;
@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) id value;

- (BOOL)satisfied;

@end
