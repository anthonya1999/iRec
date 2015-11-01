//
//  InterfaceController.h
//  Test WatchKit Extension
//
//  Created by Anthony Agatiello on 5/25/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface InterfaceController : WKInterfaceController {
    NSString *buttonText;
}

@property (weak, nonatomic) IBOutlet WKInterfaceButton *startStopButton;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *recordTimer;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *settingsLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *statusLabel;

@end