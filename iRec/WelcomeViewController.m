//
//  WelcomeViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/26/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import "WelcomeViewController.h"
#import "TermsConditionsViewController.h"

@implementation WelcomeViewController

- (instancetype)init
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self = [storyboard instantiateViewControllerWithIdentifier:@"welcomeViewController"];
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
    [[self.appIconImage layer] setCornerRadius:20.0];
    _appIconImage.layer.masksToBounds = YES;
    
    [[self.doneButton layer] setBackgroundColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor];
    [[self.doneButton layer] setCornerRadius:12.0];
    [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _doneButton.layer.masksToBounds = YES;
    
    self.title = @"Welcome to iRec";
    self.navigationController.title = @"Welcome to iRec";
    self.navigationItem.title = @"Welcome to iRec";
}

- (IBAction)presentTermsConditions:(UIButton *)sender {
    TermsConditionsViewController *termsConditionsViewController = [[TermsConditionsViewController alloc] init];
    [self.navigationController pushViewController:termsConditionsViewController animated:YES];
}

@end
