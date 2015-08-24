//
//  InterfaceController.m
//  Test WatchKit Extension
//
//  Created by Anthony Agatiello on 5/25/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import "InterfaceController.h"
#import "NewRecordingViewController.h"

@interface InterfaceController () {
    NSString *buttonText;
}

@end

@implementation InterfaceController

- (NSUserDefaults *)defaults {
    NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adhoc.iRec"];
    return prefs;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:YES], @"show_done_message",
                               [NSNumber numberWithBool:YES], @"show_timer_switch",
                               [NSNumber numberWithBool:YES], @"show_status_label",
                               nil];
    [self.defaults registerDefaults:dictionary];
    [self.defaults synchronize];
  
    [_statusLabel setText:[NSString stringWithFormat:@"Status: Not Recording"]];
    [_statusLabel setTextColor:[UIColor redColor]];
    [_recordTimer setHidden:YES];
    [_recordTimer stop];
    [_settingsLabel setHidden:NO];
    buttonText = [NSString stringWithFormat:@"Start Recording"];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:buttonText];
    [attString setAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor]} range:NSMakeRange(0, attString.string.length)];
    [_startStopButton setAttributedTitle:attString];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    BOOL enabled = [self.defaults boolForKey:@"show_status_label"];
    if (enabled) {
        [_statusLabel setHidden:NO];
    }
    else {
        [_statusLabel setHidden:YES];
    }
    [self addMenuItems];
    [self addFixedMenuItems];
}

- (void)addFixedMenuItems {
    [self addMenuItemWithImageNamed:@"Gear" title:@"Settings" action:@selector(presentSettingsPopup)];
    [self addMenuItemWithItemIcon:WKMenuItemIconInfo title:@"Info" action:@selector(presentInfo)];
    [self addMenuItemWithImageNamed:@"Group" title:@"Developers" action:@selector(presentDevelopers)];
}

- (void)addMenuItems {
    [self clearAllMenuItems];
    if ([buttonText isEqualToString:[NSString stringWithFormat:@"Start Recording"]]) {
        [self addMenuItemWithItemIcon:WKMenuItemIconPlay title:[NSString stringWithFormat:@"Start Recording"] action:@selector(startStopRecording)];
    }
    else if ([buttonText isEqualToString:[NSString stringWithFormat:@"Stop Recording"]]) {
        [self addMenuItemWithItemIcon:WKMenuItemIconDecline title:[NSString stringWithFormat:@"Stop Recording"] action:@selector(startStopRecording)];
    }
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)presentSettingsPopup {
    [self presentControllerWithName:@"settingsInterfaceController" context:nil];
}

- (IBAction)presentInfo {
    [self presentControllerWithName:@"infoInterfaceController" context:nil];
}

- (IBAction)presentDevelopers {
    [self presentControllerWithName:@"developersInterfaceController" context:nil];
}

- (IBAction)startStopRecording {
    if ([buttonText isEqualToString:[NSString stringWithFormat:@"Start Recording"]]) {
        
        [self presentTextInputControllerWithSuggestions:@[@"My New Recording"] allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
            if (results && results.count > 0) {

            buttonText = [NSString stringWithFormat:@"Stop Recording"];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:buttonText];
            [attString setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(0, attString.string.length)];
            [_startStopButton setAttributedTitle:attString];
            [_statusLabel setText:[NSString stringWithFormat:@"Status: Recording"]];
            [_statusLabel setTextColor:[UIColor greenColor]];
            
            BOOL enabled = [self.defaults boolForKey:@"show_timer_switch"];
            
            if (enabled) {
                [_recordTimer setHidden:NO];
            }
            else {
                [_recordTimer setHidden:YES];
            }
            
            [_recordTimer setDate:[NSDate dateWithTimeIntervalSinceNow:-1]];
            [_recordTimer start];
            [_settingsLabel setHidden:YES];
                
            [self addMenuItems];
            [self addFixedMenuItems];
                
            }
        }];
    }
    
    else if ([buttonText isEqualToString:[NSString stringWithFormat:@"Stop Recording"]]) {
        buttonText = [NSString stringWithFormat:@"Start Recording"];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:buttonText];
        [attString setAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor]} range:NSMakeRange(0, attString.string.length)];
        [_startStopButton setAttributedTitle:attString];
        [_recordTimer stop];
        [_recordTimer setHidden:YES];
        [_settingsLabel setHidden:NO];
        [_statusLabel setText:[NSString stringWithFormat:@"Status: Not Recording"]];
        [_statusLabel setTextColor:[UIColor redColor]];
        
        [self addMenuItems];
        [self addFixedMenuItems];
        
        BOOL enabled = [self.defaults boolForKey:@"show_done_message"];
        if (enabled) {
            [self presentControllerWithName:@"finishedInterfaceController" context:nil];
        }
    }
}

@end



