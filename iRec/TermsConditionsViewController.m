//
//  TermsConditionsViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 5/5/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import "TermsConditionsViewController.h"
#import "UIAlertView+RSTAdditions.h"
#import <FXBlurView/FXBlurView.h>

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

    if ([self.defaults boolForKey:@"dark_theme_switch"]) {
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
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:self.view.frame];
    [blurView setDynamic:YES];
    blurView.tintColor = [UIColor clearColor];
    blurView.blurRadius = 8;
    [self.view addSubview:blurView];
    
    [dismissTermsAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {

        if (buttonIndex == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [blurView removeFromSuperview];
        }
        if (buttonIndex == 0) {
            [blurView removeFromSuperview];
        }
    }];
}

- (void)disagreeToTerms {
    UIAlertView *disagreeAlert = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"You must agree to the iRec & Emu4iOS terms and conditions to use the application." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:self.view.frame];
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
    if ([self.defaults boolForKey:@"dark_theme_switch"]) {
        [headerFooterView.textLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        [headerFooterView.textLabel setTextColor:[UIColor blackColor]];
    }
    [headerFooterView.textLabel setAlpha:0.7];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *)view;
    if ([self.defaults boolForKey:@"dark_theme_switch"]) {
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
             footerText = @"The company (and/or group) Emu4iOS and its subsidiaries [\"Emu4iOS\"] are absolved from any responsibility for the incorrect usage of this site [\"https://emu4ios.net\"]. Any potential issues arising are entirely on you [\"the user visiting this site\"]. Please comply with all forms of legal rules and regulations applicable in your area. We, Emu4iOS, provide the web site [https://emu4ios.net] for installing emulators and apps as-is.\n\nAny application [\"Software, IPA (\"iPhone App\"), Plist\"] you download on this site [\"https://emu4ios.net\"] should be consciously done knowing that you [\"the user\"] will take into account full responsibility of any harmful occurence.\n\nEmu4iOS is not responsible for, and expressly disclaims all liability and accounts for damages you may incur by the usage of this site [\"https://emu4ios.net\"] to any of your [\"the user's\"] devices.\n\nEmu4iOS claims no ownership of any of the applications on this site [\"https://emu4ios.net\"] unless stated otherwise. We [\"Emu4iOS\"] respect each individual developer's copyright. Developers may contact us directly to take action in removing applications that violates their copyright and we, [\"Emu4iOS\"] will comply in removing after further research and verification of ownership.\n\nEmu4iOS does claim ownership and holds copyright to the applications [\"IPA\"] Emu4iOS Store [\"software\"] and to iRec [\"software\"]. These applications [\"IPA\"] have been coded and developed by Emu4iOS.\n\nAlthough the Emu4iOS web site [\"https://emu4ios.net\"] may include links providing direct access to other Internet resources, including external websites, Emu4iOS is not responsible for the accuracy or content of information contained in these sites unless stated otherwise. Browse such sites at your own risk.\n\nEmu4iOS in no way condones piracy. We [\"Emu4iOS\"] do not expressively directs users to download illegal ROMs or games. We [\"Emu4iOS\"] are in no way associated with sites that distribute illegaly-obtained ROMs or games.\n\nLinks from this site [\"https://emu4ios.net\"] to third-party sites and/or hosts do not constitute an endorsement by Emu4iOS of the parties or their products and services.\n\nEmu4iOS holds the right to advertise on the site [\"https://emu4ios.net\"] in order to pay for the site's [\"https://emu4ios.net\"] usage, man-power, resources, hosting bills, domain bills, and updates. Emu4iOS will never include advertisements inside applications [\"software, IPA (\"iPhone App\"), Plist\"] not legally owned by this site [\"https://emu4ios.net\"].\n\nCopyright (c) 2015 - Emu4iOS\n\nAll applications hosted on Emu4iOS are legally redistributable by their own copyright. If a developer wants their application taken off of Emu4iOS or wants a change to be made, contact me immediately. I take full respect to the developers' decisions. Emu4iOS along with all applications hosted with it/on it are to be used for development/as a development tool/testing/and for learning purposes only. We are not responsible nor reliable for any damage, either be software or hardware, to your device. This is for use at your own risk.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.";
        }
    }
    return footerText;
}


@end