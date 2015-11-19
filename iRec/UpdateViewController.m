//
//  UpdateViewController.m
//  ADA Tech Apps
//
//  Created by Anthony Agatiello on 7/24/14.
//  Copyright (c) 2014 ADA Tech, LLC. All rights reserved.
//

#import "AFNetworking.h"
#import "UpdateViewController.h"
#import "AppDelegate.h"
#import "UIAlertView+RSTAdditions.h"

#define SOFTWARE_UPDATE_ROOT_ADDRESS @"http://104.131.174.145/"

@import ObjectiveC;

@implementation UpdateViewController

- (instancetype)init
{
    return [self initWithSoftwareUpdate:nil];
}

- (instancetype)initWithSoftwareUpdate:(SoftwareUpdate *)softwareUpdate
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"softwareUpdateViewController"];
    if (self)
    {
        _softwareUpdate = softwareUpdate;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _updateImageView.layer.masksToBounds = YES;
    [[self.updateImageView layer] setCornerRadius:13.0];
    
    self.navigationItem.title = @"Software Update";
    
    self.tableView.alwaysBounceVertical = YES;
    
    self.statusLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = NSLocalizedString(@"Checking for Update…", @"");
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:15.0f];
        [label sizeToFit];
        label;
    });
    
    self.statusActivityIndicatorView = ({
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        activityIndicatorView.hidesWhenStopped = YES;
        
        activityIndicatorView;
    });
    
    UIView *view = [UIView new];
    self.tableView.backgroundView = view;
    [view addSubview:self.statusLabel];
    [view addSubview:self.statusActivityIndicatorView];
    
    NSMutableArray *constraints = [NSMutableArray array];
    
    self.statusLabelHorizontalLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.statusLabel
                                                                              attribute:NSLayoutAttributeCenterX
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.tableView.backgroundView
                                                                              attribute:NSLayoutAttributeCenterX
                                                                             multiplier:1.0
                                                                               constant:0.0];
    [constraints addObject:self.statusLabelHorizontalLayoutConstraint];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.statusLabel
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.tableView.backgroundView
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.statusActivityIndicatorView
                                                        attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.statusLabel
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0
                                                         constant:5.0]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.statusActivityIndicatorView
                                                        attribute:NSLayoutAttributeCenterY
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.tableView.backgroundView
                                                        attribute:NSLayoutAttributeCenterY
                                                       multiplier:1.0
                                                         constant:0.0]];
    
    [self.tableView.backgroundView addConstraints:constraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.updateDictionary == nil)
    {
        [self checkForUpdate];
    }
}

#pragma mark - Check For Update

- (void)checkForUpdate
{
    CGFloat constant = -((CGRectGetWidth(self.statusLabel.bounds) + CGRectGetWidth(self.statusActivityIndicatorView.bounds) + 5) - CGRectGetWidth(self.statusLabel.bounds))/2.0f;
    self.statusLabelHorizontalLayoutConstraint.constant = constant;
    self.statusLabel.text = NSLocalizedString(@"Checking for Update…", @"");
    
    [self.tableView.backgroundView updateConstraints];
    
    [self.statusActivityIndicatorView startAnimating];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *address = [SOFTWARE_UPDATE_ROOT_ADDRESS stringByAppendingPathComponent:@"iRecUpdate.json"];
    NSURL *URL = [NSURL URLWithString:address];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, NSDictionary *jsonObject, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.statusActivityIndicatorView stopAnimating];
            self.statusLabelHorizontalLayoutConstraint.constant = 0;
            
            if (error)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithError:error cancelButtonTitle:NSLocalizedString(@"Cancel", @"")];
                [alert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
                
                self.statusLabel.text = NSLocalizedString(@"Failed to check for update.", @"");
                
                [UIView transitionWithView:self.statusLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    [self.tableView.backgroundView layoutIfNeeded];
                } completion:nil];
                
                return;
            }
            
            if (![self bundleVersionIsOlderThanUpdate:jsonObject])
            {
                NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
                NSString *upToDateMessage = [NSString stringWithFormat:@"iRec %@\n%@", bundleVersion, NSLocalizedString(@"Your software is up to date.", @"")];
                
                self.statusLabel.text = upToDateMessage;
                
                [UIView transitionWithView:self.statusLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    [self.tableView.backgroundView layoutIfNeeded];
                } completion:nil];
                
                return;
            }
            
            self.updateDictionary = jsonObject;
            [self refreshViewWithSoftwareUpdateInfo];
            
        });
        
    }];
    
    [dataTask resume];
}

- (void)refreshViewWithSoftwareUpdateInfo
{
    self.softwareUpdateNameLabel.text = self.updateDictionary[@"name"];
    self.softwareUpdateDeveloperLabel.text = self.updateDictionary[@"developer"];
    self.softwareUpdateDescriptionTextView.text = self.updateDictionary[@"description"];
    
    long long numberOfBytes = [self.updateDictionary[@"size"] longLongValue];
    self.softwareUpdateSizeLabel.text = [NSByteCountFormatter stringFromByteCount:numberOfBytes countStyle:NSByteCountFormatterCountStyleFile];
    
    [UIView transitionWithView:self.tableView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.statusLabel.alpha = 0.0;
        [self.tableView reloadData];
    } completion:nil];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.updateDictionary == nil)
    {
        return 0;
    }
    
    return [super numberOfSectionsInTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 70 + [self.softwareUpdateDescriptionTextView sizeThatFits:CGSizeMake(CGRectGetWidth(self.softwareUpdateDescriptionTextView.bounds), FLT_MAX)].height + 1; // Add one to ensure iOS 7 UITextView displays all lines of text
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to update iRec?", @"")
                                                        message:NSLocalizedString(@"Click install on the next prompt to update iRec. Please make sure you have a good internet connection.", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"Update", @""), nil];
        [alert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex == 1)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateDictionary[@"url"]]];
                [AppDelegate suspendApp];
            }
            
        }];
    }
    
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Helper Methods


- (BOOL)bundleVersionIsOlderThanUpdate:(NSDictionary *)updateDictionary
{
    return ([[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey] compare:updateDictionary[@"version"] options:NSNumericSearch] == NSOrderedAscending);
}




@end
