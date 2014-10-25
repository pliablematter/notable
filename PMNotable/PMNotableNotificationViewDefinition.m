//
//  PMNotableNotificationViewDefinition.m
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotableNotificationViewDefinition.h"

@implementation PMNotableNotificationViewDefinition

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _viewID = @"";
        _file = @"";
        _height = [UIScreen mainScreen].bounds.size.height;
        _origin = PMViewOriginBottom;
    }
    return self;
}

#pragma mark - Public

- (void)parseJSONObject:(id)JSONObject
{
    if ([JSONObject objectForKey:@"file"])
    {
        self.file = [JSONObject objectForKey:@"file"];
    }
    
    if ([JSONObject objectForKey:@"height"])
    {
        self.height = [[JSONObject objectForKey:@"height"] floatValue];
    }
    
    if ([JSONObject objectForKey:@"origin"])
    {
        NSString *origin = [JSONObject objectForKey:@"origin"];
        
        if ([origin isEqualToString:@"bottom"])
        {
            _origin = PMViewOriginBottom;
        }
        else if ([origin isEqualToString:@"top"])
        {
            _origin = PMViewOriginTop;
        }
    }
}

#pragma mark - Memory management

- (void)dealloc
{
    _viewID = nil;
    _file = nil;
}

@end
