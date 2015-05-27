//
//  InterfaceController.m
//  Test WatchKit Extension
//
//  Created by Anthony Agatiello on 5/25/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController () {
    NSString *buttonText;
}

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adhoc.iRec"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"show_done_message", [NSNumber numberWithBool:YES], @"show_timer_switch", nil];
    [defaults registerDefaults:dictionary];
    [defaults synchronize];
    
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

- (IBAction)startStopRecording:(WKInterfaceButton *)sender {
    if ([buttonText isEqualToString:[NSString stringWithFormat:@"Start Recording"]]) {
        
        [self presentTextInputControllerWithSuggestions:@[@"My New Recording"] allowedInputMode:WKTextInputModePlain completion:^(NSArray *results) {
            if (results && results.count > 0) {

            buttonText = [NSString stringWithFormat:@"Stop Recording"];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:buttonText];
            [attString setAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} range:NSMakeRange(0, attString.string.length)];
            [_startStopButton setAttributedTitle:attString];
            
            NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adhoc.iRec"];
            BOOL enabled = [defaults boolForKey:@"show_timer_switch"];
            
            if (enabled) {
                [_recordTimer setHidden:NO];
            }
            
            [_recordTimer setDate:[NSDate dateWithTimeIntervalSinceNow:-1]];
            [_recordTimer start];
            [_settingsLabel setHidden:YES];
                
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
        
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.adhoc.iRec"];
        BOOL enabled = [defaults boolForKey:@"show_done_message"];
        if (enabled) {
            [self presentControllerWithName:@"finishedInterfaceController" context:nil];
        }
    }
}

@end



