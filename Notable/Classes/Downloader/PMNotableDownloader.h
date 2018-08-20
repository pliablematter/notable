//
//  PMNotableDownloader.h
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMNotableDownloader : NSObject

- (void)requestControlFile:(NSString *)controlFile
              successBlock:(void (^)(id controlJSON))successBlock
                errorBlock:(void (^)(NSError *error))errorBlock;

@end
