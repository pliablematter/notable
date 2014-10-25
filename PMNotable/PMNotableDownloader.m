//
//  PMNotableDownloader.m
//  PMNotable
//
//  Created by Igor Milakovic on 25/10/14.
//  Copyright (c) 2014 Pliable Matter LLC. All rights reserved.
//

#import "PMNotableDownloader.h"

#define PM_CONTROL_FILE_LAST_DOWNLOAD_DATE_KEY @"kControlFileLastDownloadDateKey"

@implementation PMNotableDownloader

#pragma mark - Public

- (void)requestControlFile:(NSString *)controlFile
              successBlock:(void (^)(id controlJSON))successBlock
                errorBlock:(void (^)(NSError *error))errorBlock
{
    NSDate *lastDownloadDate = [[NSUserDefaults standardUserDefaults] objectForKey:PM_CONTROL_FILE_LAST_DOWNLOAD_DATE_KEY];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:controlFile]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod:@"HEAD"];
    [request setValue:[self lastModifiedDateStringFromDate:lastDownloadDate] forHTTPHeaderField:@"If-Modified-Since"];
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (connectionError)
        {
            if (errorBlock)
            {
                errorBlock(connectionError);
            }
            
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (httpResponse.statusCode == 200)
        {
            [self downloadControlFile:controlFile successBlock:successBlock errorBlock:errorBlock];
        }
        else if (httpResponse.statusCode == 304)
        {
            [self loadControlFile:controlFile successBlock:successBlock errorBlock:errorBlock];
        }
    }];
}

#pragma mark - File

- (void)downloadControlFile:(NSString *)controlFile
               successBlock:(void (^)(id controlJSON))successBlock
                 errorBlock:(void (^)(NSError *error))errorBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:controlFile]];
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        if (data)
        {
            NSError *error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            
            if (jsonObject && !error)
            {
                if (successBlock)
                {
                    successBlock(jsonObject);
                }
                
                [data writeToFile:[[self cachesDirectoryPath] stringByAppendingPathComponent:controlFile.lastPathComponent] atomically:YES];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:PM_CONTROL_FILE_LAST_DOWNLOAD_DATE_KEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                if (errorBlock)
                {
                    errorBlock(error);
                }
            }
        }
        else
        {
            if (errorBlock)
            {
                errorBlock(connectionError);
            }
        }
    }];
}

- (void)loadControlFile:(NSString *)controlFile
           successBlock:(void (^)(id controlJSON))successBlock
             errorBlock:(void (^)(NSError *error))errorBlock
{
    NSString *path = [[self cachesDirectoryPath] stringByAppendingPathComponent:controlFile.lastPathComponent];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:[[self cachesDirectoryPath] stringByAppendingPathComponent:controlFile.lastPathComponent]];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (jsonObject)
        {
            if (successBlock)
            {
                successBlock(jsonObject);
            }
        }
        else
        {
            if (errorBlock)
            {
                errorBlock(error);
            }
        }
    }
    else
    {
        if (errorBlock)
        {
            errorBlock(nil);
        }
    }
}

#pragma mark - Helpers

- (NSString *)cachesDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    if (paths && paths.count > 0)
    {
        return [paths firstObject];
    }
    
    return nil;
}

- (NSString *)lastModifiedDateStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    
    return [[dateFormatter stringFromDate:date] stringByAppendingString:@" GMT"];
}

@end
