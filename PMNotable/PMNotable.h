//
//  PMNotable.h
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMNotable : NSObject
{
    NSMutableArray *_notifications;
}

// Singleton
+ (instancetype)sharedInstance;

// Update
- (void)updateWithControlFile:(NSString *)controlFile;

@end
