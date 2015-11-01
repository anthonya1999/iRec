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

@property (strong, nonatomic) SoftwareUpdate *softwareUpdate;

@property (copy, nonatomic) NSDictionary *updateDictionary;

@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIActivityIndicatorView *statusActivityIndicatorView;
@property (strong, nonatomic) NSLayoutConstraint *statusLabelHorizontalLayoutConstraint;

@property (weak, nonatomic) IBOutlet UILabel *softwareUpdateNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareUpdateDeveloperLabel;
@property (weak, nonatomic) IBOutlet UILabel *softwareUpdateSizeLabel;
@property (weak, nonatomic) IBOutlet UITextView *softwareUpdateDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *updateImageView;

- (instancetype)initWithSoftwareUpdate:(SoftwareUpdate *)softwareUpdate;

@end