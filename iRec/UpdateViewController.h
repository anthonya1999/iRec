//
//  UpdateViewController.h
//  ADA Tech Apps
//
//  Created by Anthony Agatiello on 7/24/14.
//  Copyright (c) 2014 ADA Tech, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SoftwareUpdate;

@interface UpdateViewController : UITableViewController

- (instancetype)initWithSoftwareUpdate:(SoftwareUpdate *)softwareUpdate;

@end
