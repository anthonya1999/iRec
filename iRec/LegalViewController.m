//
//  LegalViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 3/23/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import "LegalViewController.h"

@interface LegalViewController ()

@end

@implementation LegalViewController

- (instancetype)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self)
    {
        self.title = @"Legal Agreement";
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
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = nil;
    if (tableView) {
        if (section == 0) {
            NSError *error = nil;
            NSString *pathToLegalText = [[NSBundle mainBundle] pathForResource:@"LegalText" ofType:@"txt"];
            footerText = [NSString stringWithContentsOfFile:pathToLegalText encoding:NSUTF8StringEncoding error:&error];
        }
    }
    return footerText;
}

@end