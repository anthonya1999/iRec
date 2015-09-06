//
//  TermsConditionsViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 5/5/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import "TermsConditionsViewController.h"
#import "UIAlertView+RSTAdditions.h"
#import "FXBlurView.h"

@interface TermsConditionsViewController ()

@end

@implementation TermsConditionsViewController

- (NSUserDefaults *)defaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return prefs;
}

- (instancetype)init
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self)
    {
        self.title = @"Terms and Conditions";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *disagreeButton = [[UIBarButtonItem alloc] initWithTitle:@"Disagree" style:UIBarButtonItemStyleBordered target:self action:@selector(disagreeToTerms)];
    UIBarButtonItem *agreeButton = [[UIBarButtonItem alloc] initWithTitle:@"Agree" style:UIBarButtonItemStyleDone target:self action:@selector(dismissTermsConditions)];
    NSArray *items = [NSArray arrayWithObjects:disagreeButton, flexibleSpace, agreeButton, nil];
    self.toolbarItems = items;

    if ([[self.defaults objectForKey:@"theme_value"] isEqualToString:@"darkTheme"]) {
        self.navigationController.toolbar.barTintColor = [UIColor blackColor];
        disagreeButton.tintColor = [UIColor whiteColor];
        agreeButton.tintColor = [UIColor whiteColor];
        self.tableView.backgroundColor = [UIColor blackColor];
    }
    else {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)dismissTermsConditions {
    UIAlertView *dismissTermsAlert = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"I agree to the iRec & Emu4iOS terms and conditions." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Agree", nil];
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height * 4)];
    [blurView setDynamic:YES];
    blurView.tintColor = [UIColor clearColor];
    blurView.blurRadius = 8;
    [self.view addSubview:blurView];
    
    [dismissTermsAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {

        if (buttonIndex == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [blurView removeFromSuperview];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"showedWarningAlert"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if (buttonIndex == 0) {
            [blurView removeFromSuperview];
        }
    }];
}

- (void)disagreeToTerms {
    UIAlertView *disagreeAlert = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"You must agree to the iRec & Emu4iOS terms and conditions to use the application." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height * 4)];
    [blurView setDynamic:YES];
    [blurView setDynamic:YES];
    blurView.tintColor = [UIColor clearColor];
    blurView.blurRadius = 8;
    [self.view addSubview:blurView];

    [disagreeAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [blurView removeFromSuperview];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    if ([[self.defaults objectForKey:@"theme_value"] isEqualToString:@"darkTheme"]) {
        [headerFooterView.textLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [headerFooterView.textLabel setTextColor:[UIColor blackColor]];
    }
    [headerFooterView.textLabel setAlpha:0.7];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    if ([[self.defaults objectForKey:@"theme_value"] isEqualToString:@"darkTheme"]) {
        [headerFooterView.textLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [headerFooterView.textLabel setTextColor:[UIColor blackColor]];
    }
    [headerFooterView.textLabel setAlpha:1.0];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = nil;
    if (tableView) {
        if (section == 0) {
            headerText = @"Important\n\nPlease read the following terms before using iRec. By using iRec, you are agreeing to be bound by the Terms and Conditions.";
        }
    }
    return headerText;
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