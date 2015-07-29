//
//  AboutInterfaceController.h
//  iRec
//
//  Created by Anthony Agatiello on 5/25/15.
//  Copyright (c) 2015 ADA Tech, LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface AboutInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *versionLabel;

@end