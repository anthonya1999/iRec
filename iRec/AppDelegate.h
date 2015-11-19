//
//  AppDelegate.h
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Private.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

+ (void)suspendApp;

@property (strong, nonatomic) UIWindow *window;

@end