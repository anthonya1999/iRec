//
//  SoftwareUpdateOperation.m
//  ScreenRecord
//
//  Created by Anthony Agatiello on 7/13/14.
//  Copyright (c) 2014 Anthony Agatiello. All rights reserved.
//

#import "SoftwareUpdateOperation.h"

#import <AFNetworking/AFNetworking.h>
#import "AFNetworkActivityIndicatorManager.h"

static NSString * const SoftwareUpdateRootAddress = @"http://104.131.174.145/";

@implementation SoftwareUpdateOperation

- (void)checkForUpdateWithCompletion:(SoftwareUpdateCompletionBlock)completionBlock
{
    if (self.performsNoOperation)
    {
        if (completionBlock)
        {
            completionBlock(nil, nil);
        }
        
        return;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *address = [SoftwareUpdateRootAddress stringByAppendingPathComponent:@"iRecUpdate.json"];
    NSURL *URL = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *error) {
        
        SoftwareUpdate *softwareUpdate = [[SoftwareUpdate alloc] initWithDictionary:jsonObject];
        
        //DLog(@"Found software update: %@", softwareUpdate);
        
        completionBlock(softwareUpdate, error);
    }];
    
   // DLog(@"Checking for Software Updates...");
    
    [dataTask resume];
}

@end
