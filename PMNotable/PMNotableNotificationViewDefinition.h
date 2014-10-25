//
//  PMNotableNotificationViewDefinition.h
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PMViewOrigin)
{
    PMViewOriginBottom,
    PMViewOriginTop
};

@interface PMNotableNotificationViewDefinition : NSObject

@property (strong, nonatomic) NSString *viewID;
@property (strong, nonatomic) NSString *file;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) PMViewOrigin origin;

- (void)parseJSONObject:(id)JSONObject;

@end
