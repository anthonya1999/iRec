//
//  AppDelegate.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <Parse/Parse.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "UpdateViewController.h"
#import "NewRecordingViewController.h"
#import "SoftwareUpdate.h"
#import "SoftwareUpdateOperation.h"
#import "NSDate+Comparing.h"
#import "UIAlertView+RSTAdditions.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "WelcomeViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static NSString * const CachedSoftwareUpdateKey = @"cachedSoftwareUpdate";
static NSString * const AppVersionKey = @"appVersion";
static NSString * const LastCheckForUpdatesKey = @"lastCheckForUpdates";

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize player;
@synthesize backgroundTaskID;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[MPMusicPlayerController iPodMusicPlayer] stop];
    
    [Parse setApplicationId:@"l0lKvRthodCZ2iMpZW2AXYYtr2lzI8u2xhkJT8Kn" clientKey:@"lX13j5I2hrp5QH8KO4KLxVdPOtLknORUfYci0zog"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [self registerForRemoteNotification];
    
    //Fail-safe if the preferences file is not created...
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *bundleIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleIdentifierKey];
    NSString *plistPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Preferences/%@.plist",bundleIdentifier]];
    
    if (![fileManager fileExistsAtPath:plistPath]) {
        NSData *contents = nil;
        NSDictionary *attributes = nil;
        [fileManager createFileAtPath:plistPath contents:contents attributes:attributes];
    }
    else {
        //do nothing...
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"showedWarningAlert"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            WelcomeViewController *welcomeViewController = [[WelcomeViewController alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
            [self.window makeKeyAndVisible];
            [self.window.rootViewController presentViewController:navigationController animated:YES completion:NULL];
        });
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"showedWarningAlert"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSLog(@"Registering default values from Settings.bundle");
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs synchronize];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if(!settingsBundle)
    {
        NSLog(@"Could not find Settings.bundle");
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    
    for (NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key)
        {
            // check if value readable in userDefaults
            id currentObject = [defs objectForKey:key];
            if (currentObject == nil)
            {
                // not readable: set value from Settings.bundle
                id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                [defaultsToRegister setObject:objectToSet forKey:key];
                NSLog(@"Setting object %@ for key %@", objectToSet, key);
            }
            else
            {
                // already readable: don't touch
                NSLog(@"Key %@ is readable (value: %@), nothing written to defaults.", key, currentObject);
            }
        }
    }

    if ([defs boolForKey:@"dark_theme_switch"]) {
        [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];

    }
    else {
        //Only change the status bar color...
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    }
    
    [defs registerDefaults:defaultsToRegister];
    [defs synchronize];
    
    [self preparePushNotifications];
    
    [Fabric with:@[CrashlyticsKit]];
    
    return YES;
}

- (void)performChecksForSoftwareUpdatesWithCompletion:(void (^)(SoftwareUpdate *))softwareUpdateCompletionBlock

                     backgroundFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    SoftwareUpdateOperation *softwareUpdateOperation = [SoftwareUpdateOperation new];
    
    
    [softwareUpdateOperation checkForUpdateWithCompletion:^(SoftwareUpdate *softwareUpdate, NSError *error) {
        
        // Don't return if softwareUpdate is nil, in case we perform no network operation
        
        if (error)
        {
            NSLog(@"%@",error);
            
            if (completionHandler)
            {
                completionHandler(UIBackgroundFetchResultFailed);
            }
            
            return;
        }
        
        NSString *cachedSoftwareUpdateVersion = [[NSUserDefaults standardUserDefaults] objectForKey:CachedSoftwareUpdateKey];
        
        __block UIBackgroundFetchResult backgroundFetchResult = UIBackgroundFetchResultNoData;
        
        if (![cachedSoftwareUpdateVersion isEqualToString:softwareUpdate.version] && [softwareUpdate isNewerThanAppVersion] && [softwareUpdate isSupportedOnCurrentiOSVersion])
        {
            if (softwareUpdateCompletionBlock)
            {
                softwareUpdateCompletionBlock(softwareUpdate);
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:softwareUpdate.version forKey:CachedSoftwareUpdateKey];
            
            backgroundFetchResult = UIBackgroundFetchResultNewData;
        }
        else
        {
            NSLog(@"Software update is not new.");
        }
    }];
}

- (void)preparePushNotifications
{
    // Uncomment to removed cached events and update information
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:CachedSoftwareUpdateKey];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:CachedEventDistributionsKey];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1 * 60 * 60 * 24]; // Check approximately once a day
    
    if ([UIUserNotificationSettings class])
    {
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    
    // Delay until after app boots up
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *previousAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:AppVersionKey];
        NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
        // No previous version, or current app version is newer than previous
        if (!previousAppVersion || [previousAppVersion compare:currentAppVersion options:NSNumericSearch] == NSOrderedAscending)
        {
            [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:AppVersionKey];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        }
        
        // Manually check for updates
        NSDate *lastManualFetch = [[NSUserDefaults standardUserDefaults] objectForKey:LastCheckForUpdatesKey];
        NSInteger daysPassed = [[NSDate date] daysSinceDate:lastManualFetch];
        
        if (!lastManualFetch || daysPassed > 0)
        {
            [self manuallyCheckForUpdates];
            
        }
        
        
        
    });
    
}


- (void)manuallyCheckForUpdates
{
    [self performChecksForSoftwareUpdatesWithCompletion:^(SoftwareUpdate *softwareUpdate) {
        // Software Update Available
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
            
            NSString *updateMessage = [NSString stringWithFormat:@"%@ %@", softwareUpdate.name, NSLocalizedString(@"is now available for download. Please update now to continue using iRec.", @"")];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Software Update Available", @"")
                                                            message:updateMessage
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Update Now", nil];
            
            
            
            [alert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if (buttonIndex == 0)
                {
                    UpdateViewController *updateViewController = [[UpdateViewController alloc] init];
                    
                    [[UIApplication sharedApplication] setStatusBarStyle:[updateViewController preferredStatusBarStyle] animated:YES];
                    
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:updateViewController];
                    
                    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
                    {
                        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    }
                    [self.window makeKeyAndVisible];
                    [self.window.rootViewController presentViewController:navigationController animated:YES completion:NULL];
                    
                }
                
            }];
            
        });
        
    }  backgroundFetchCompletionHandler:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastCheckForUpdatesKey];
}



- (void)registerForRemoteNotification {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)backgroundForever {
    backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self backgroundForever];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        NSLog(@"Application will run in background forever until the task is stopped.");
    }];
}

- (void)stopBackgroundTask {
    if (backgroundTaskID != -1)
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        NSLog(@"Background task ended.");
}

- (void)playMP3 {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/blank.mp3"];
    NSURL *fileURL = [NSURL fileURLWithPath:resourcePath];
    NSError *error = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    player.delegate = self;
    [player play];
    player.numberOfLoops = -1;
    player.currentTime = 0;
    player.volume = 1.0;
    NSLog(@"Started playing file: %@", resourcePath);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self backgroundForever];
    [self playMP3];
    NSLog(@"Application entered background.");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self stopBackgroundTask];
    [player stop];
    NSLog(@"Application entered foreground.");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
