//
//  WatchSupportViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 5/25/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import "WatchSupportViewController.h"

@interface WatchSupportViewController ()

@end

@implementation WatchSupportViewController

- (instancetype)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self)
    {
        self.title = @"Watch Support Info";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = nil;
    if (tableView) {
        if (section == 0) {
            headerText = @"iRec Remote for Apple Watch";
        }
    }
    return headerText;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = nil;
    if (tableView) {
        if (section == 0) {
            footerText = @"iRec 1.2+ now has support for the Apple Watch! It actually, does not record the watch screen itself, but is a remote for iRec on your device (iPhone only, of course). You can control whether to record audio or not, and you can start/stop recording accordingly. Also, on the watch, is a timer. So now, you can see how long you have been recording for on your iPhone. (Note: This feature is only available if you start recording on your watch.)";
        }
    }
    return footerText;
}


@end
