//
//  AppDelegate.h
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate> {
    AVAudioPlayer *player;
    UIBackgroundTaskIdentifier backgroundTaskID;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) AVAudioPlayer *player;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskID;

@end