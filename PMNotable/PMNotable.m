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

- (void)parseControlJSON:(id)controlJSON
{
    for (NSString *key in [controlJSON allKeys])
    {
        PMNotableNotification *notification = [PMNotableNotification new];
        notification.notificationID = key;
        [notification parseJSONObject:[controlJSON objectForKey:key]];
        
        if ([notification conditionsSatisfied])
        {
            NSLog(@"show %@", notification.entry);
        }
        else
        {
            NSLog(@"don't show");
        }
    }
}

@end
