//
//  SoftwareUpdateOperation.h
//  ScreenRecord
//
//  Created by Anthony Agatiello on 7/13/14.
//  Copyright (c) 2014 Anthony Agatiello. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SoftwareUpdate.h"

typedef void (^SoftwareUpdateCompletionBlock)(SoftwareUpdate *softwareUpdate, NSError *error);

@interface SoftwareUpdateOperation : NSObject

@property (nonatomic, assign) BOOL performsNoOperation;

- (void)checkForUpdateWithCompletion:(SoftwareUpdateCompletionBlock)completionBlock;

@end
