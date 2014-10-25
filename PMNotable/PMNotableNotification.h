//
//  PMNotableNotification.h
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMNotableNotification : NSObject

@property (strong, nonatomic) NSString *notificationID;
@property (strong, nonatomic) NSMutableArray *allConditions; // of PMNotableNotificationCondition
@property (strong, nonatomic) NSMutableArray *anyConditions; // of PMNotableNotificationCondition
@property (strong, nonatomic) NSString *entry;
@property (strong, nonatomic) NSMutableArray *viewDefinitions; // of PMNotableNotificationViewDefinition

- (BOOL)conditionsSatisfied;
- (void)parseJSONObject:(id)JSONObject;

@end
