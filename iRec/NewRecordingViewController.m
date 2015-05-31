//
//  NewRecordingViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "NewRecordingViewController.h"
#import "ScreenRecorder.h"
#import "WelcomeViewController.h"
#import "UIAlertView+RSTAdditions.h"
#import "UIImage+ImageEffects.h"

@implementation NewRecordingViewController {
    BOOL isAudioRec;
    NSString* shareString1;
    NSString* copyString;
}

@synthesize isRecording = _isRecording;

CGFloat degreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
};

- (NSUserDefaults *)defaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return prefs;
}

- (id) init
{
    self = [super init];
    
    if(self != nil)
    {
        shareString1 = @"Record your iOS devices' screen with iRec! itms-services://?action=download-manifest&url=https://emu4ios.net/ESM/iRec.plist";
        copyString = @"Download link: itms-services://?action=download-manifest&url=https://emu4ios.net/ESM/iRec.plist";
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            return 3;
        }
    }
    return 2;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return shareString1;
    return copyString;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if([activityType isEqualToString:UIActivityTypeAirDrop])
    {
        return [NSURL URLWithString:@"itms-services://?action=download-manifest&url=https://emu4ios.net/ESM/iRec.plist"];
    }
    if([activityType isEqualToString:UIActivityTypeCopyToPasteboard])
    {
        return copyString;
    }
    else
    {
        return shareString1;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)otherMediaIsPlaying {
    if ([[AVAudioSession sharedInstance] isOtherAudioPlaying] == YES) {
        goto fail;
    }
    return NO;
    
fail:
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, 0);
    [self.view.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    viewImage = [viewImage applyBlurWithRadius:4.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
    UIImageView *blurredView = [[UIImageView alloc] initWithImage:viewImage];
    [self.view addSubview:blurredView];
    UIGraphicsEndImageContext();
    
    UIAlertView *musicAlert = nil;
    NSString *musicAlertText = nil;
    
    if (_recorder != nil) {
        if (_recorder) {
            musicAlertText = @"Other media is currently playing. To save the recording, you must stop the existing audio.";
            musicAlert = [[UIAlertView alloc] initWithTitle:@"3rd Party Audio" message:musicAlertText delegate:self cancelButtonTitle:nil otherButtonTitles:@"Stop Audio", nil];
            [musicAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    NSError *error = nil;
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
                    [[AVAudioSession sharedInstance] setActive:YES error:&error];
                    [[AVAudioSession sharedInstance] setActive:NO error:&error];
                    [blurredView removeFromSuperview];
                    [self startStopRecording];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                    [self setButtonTextToNormal];
                }
            }];
        }
    }
    
    if (_recorder == nil) {
        if (!_recorder) {
            musicAlertText = @"Other audio from another source is currently playing from the device. In order for iRec to properly record, the audio must be stopped. Would you like to exit the app, or stop the audio?";
            musicAlert = [[UIAlertView alloc] initWithTitle:@"3rd Party Audio" message:musicAlertText delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:@"Stop Audio", nil];
            [musicAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    exit(0);
                }
                if (buttonIndex == 1) {
                    NSError *error = nil;
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
                    [[AVAudioSession sharedInstance] setActive:YES error:&error];
                    [[AVAudioSession sharedInstance] setActive:NO error:&error];
                    [blurredView removeFromSuperview];
                    [self startStopRecording];
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
                }
            }];
        }
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString* certPath = [[NSBundle mainBundle] pathForResource:@"iRec Beta" ofType:@"cer"];
    if (certPath==nil) {
        NSLog(@"Certificate not found in app bundle!");
    }
    NSData* certData = [NSData dataWithContentsOfFile:certPath];
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    SecTrustRef trust;
    OSStatus err = SecTrustCreateWithCertificates((__bridge CFArrayRef) [NSArray arrayWithObject:(__bridge id)cert], policy, &trust);
    SecTrustResultType trustResult = -1;
    err = SecTrustEvaluate(trust, &trustResult);
    CFRelease(trust);
    CFRelease(policy);
    CFRelease(cert);
    
    if(trustResult == kSecTrustResultUnspecified) {
        // Profile is installed, do nothing...
    }
    else {
        // Profile not installed
        UIGraphicsBeginImageContext(self.view.bounds.size);
        CGContextRef c = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(c, 0, 0);
        [self.view.layer renderInContext:c];
        UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
        viewImage = [viewImage applyBlurWithRadius:4.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
        UIImageView *blurredView = [[UIImageView alloc] initWithImage:viewImage];
        [self.view addSubview:blurredView];
        UIGraphicsEndImageContext();
        
        UIAlertView *certAlert = [[UIAlertView alloc] initWithTitle:@"Authorization Required" message:@"In order to use iRec, you must get permission with the developer(s) to do so. A profile, which is not currently on your device, that authorizes you to use iRec, must be installed before you can use this beta." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [certAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [blurredView removeFromSuperview];
                exit(0);
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.defaults boolForKey:@"dark_theme_switch"]) {
        _shareButtonOutlet.tintColor = [UIColor whiteColor];
    }
    else {
        //do nothing different...
    }
    
    self.isRecording = NO;
    _nameField.userInteractionEnabled = YES;
    [_startStopButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    [_startStopButton setTitleColor:[UIColor colorWithRed:0/255.f green:200/255.f blue:0/255.f alpha:1.0] forState:UIControlStateNormal];
    [_startStopButton setTitleShadowColor:[UIColor colorWithRed:0/255.f green:200/255.f blue:0/255.f alpha:1.0] forState:UIControlStateNormal];
    isAudioRec = NO;
    
    
    if ([self.defaults boolForKey:@"dark_theme_switch"]) {
        _nameField.keyboardAppearance = UIKeyboardAppearanceDark;
    }
    else {
        _nameField.keyboardAppearance = UIKeyboardAppearanceLight;
    }
    
    /*
     //Need to add a check if location services are actived
     if([CLLocationManager locationServicesEnabled]){
     
     NSLog(@"Location Services Enabled");
     
     if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied){
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PLEASE READ" message:@"It is important that you allow location services for iRec. It allows to record while iRec is in multitasking for more than, the default, 3 minutes." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
     [alert show];
     }
     }
     
     //Allows for infinite backgrounding/recording. Starts location search loop
     self.locationManager = [[CLLocationManager alloc] init];
     self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
     self.locationManager.delegate = self;
     [self.locationManager startUpdatingLocation];
     */
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (!self.otherMediaIsPlaying) {
            if (_recorder == nil) {
                if (!self.hasValidName)
                    goto deselect;
                /*
                 Now uses AppDelegate to handle when app goes into background/foreground.
                 [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]; //temp hack for 3 minutes
                 */
                _nameField.userInteractionEnabled = NO;
                //self.tabBarController.tabBar.userInteractionEnabled = NO;
                [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
                //[self record];
                //[_startButton setAlpha:0.1];
                //[_stopButton setAlpha:1.0];
                [self startStopRecording];
            }
            
            else {
                if (_recorder) {
                    //[_recorder stopRecording];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    // _recorder = nil;
                    [self startStopRecording];
                    //self.tabBarController.tabBar.userInteractionEnabled = YES;
                    //[self setMergingText];
                    //[self performSelector:@selector(setButtonTextToNormal) withObject:nil afterDelay:5.0];
                    [self setButtonTextToNormal];
                    //[self mergeAudio];
                }
            }
        }
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                [[UIApplication sharedApplication] openURL:settingsURL];
            }
            else {
                UIAlertView *settingsAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unfortunately, you can only open the Settings app directly in iOS 8 or above. Please go to your home screen, open the Settings app, and scroll down to \"iRec\" to change the application settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [settingsAlert show];
            }
        }
    }
    
deselect:
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setTitleAndColorForButton {
    [_startStopButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
    [_startStopButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_startStopButton setTitleShadowColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (void)setMergingText {
    [_startStopButton setTitle:@"Saving...Please wait..." forState:UIControlStateNormal];
    _startStopButton.userInteractionEnabled = YES;
    self.tableView.userInteractionEnabled = NO;
    _nameField.userInteractionEnabled = NO;
}

- (void)setButtonTextToNormal {
    [_startStopButton setTitle:@"Start Recording" forState:UIControlStateNormal];
    [_startStopButton setTitleColor:[UIColor colorWithRed:0/255.f green:200/255.f blue:0/255.f alpha:1.0] forState:UIControlStateNormal];
    [_startStopButton setTitleShadowColor:[UIColor colorWithRed:0/255.f green:200/255.f blue:0/255.f alpha:1.0] forState:UIControlStateNormal];
    [_nameField setText:nil];
    _startStopButton.userInteractionEnabled = NO;
    _nameField.userInteractionEnabled = YES;
    self.tableView.userInteractionEnabled = YES;
}


#pragma mark - Data Validation

- (NSString *)filePathForRecordingNamed:(NSString *)name {
    //again, merging doesn't work on iPad...keep original name for now.
    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mov", _nameField.text]];
    
}

- (BOOL)hasValidName {
    NSString *errorText = nil;
    UIAlertView *failAlert = nil;
    
    if ([[_nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        errorText = @"Please enter a name for your new recording before continuing.";
        goto fail;
    }
    
    
    else {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:[self filePathForRecordingNamed:_nameField.text]]) {
            errorText = @"Please enter a different name, that one has already been taken.";
            goto fail;
        }
    }
    
    return YES;
    
fail:
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, 0);
    [self.view.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    viewImage = [viewImage applyBlurWithRadius:4.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
    UIImageView *blurredView = [[UIImageView alloc] initWithImage:viewImage];
    [self.view addSubview:blurredView];
    UIGraphicsEndImageContext();
    
    failAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorText delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [blurredView removeFromSuperview];
        }
    }];
    
    return NO;
}

- (int)framerate {
    //int requestedFramerate = [_framerateField.text intValue];
    int fps;
    if ([self.defaults objectForKey:@"multi_fps"])
        fps = [[self.defaults objectForKey:@"multi_fps"] doubleValue];
    return fps; //> 0 ? fps : 29.97);
}


- (int)bitrate {
    //int requestedBitrate = [text_bitrate intValue];
    int bitrate;
    if ([self.defaults objectForKey:@"multi_bitrate"])
        bitrate = [[self.defaults objectForKey:@"multi_bitrate"] doubleValue];
    return bitrate; //> 0 ? bitrate : 3500);
}

#pragma mark - IBActions

- (IBAction)textFieldDidEndEditing:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (IBAction)shareApplication:(UIBarButtonItem *)activityType {
    NewRecordingViewController* item = [[NewRecordingViewController alloc] init];
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        activityViewController.popoverPresentationController.barButtonItem = activityType;
        activityViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
}


- (void)startStopRecording
{
    NSString *urlString = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.caf", _nameField.text]];
    NSURL *fileURL = [NSURL fileURLWithPath:urlString];
    
    //If the app is not recording, we want to start recording
    if(!self.isRecording)
    {
        [self setTitleAndColorForButton];
        
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1];
        _recorder = [[ScreenRecorder alloc]initWithFramerate:self.framerate bitrate:self.bitrate];
        [_recorder setVideoPath:[self filePathForRecordingNamed:_nameField.text]];
        [_recorder startRecording];
        
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&sessionError];
        
        NSError *speakerError = nil;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&speakerError];
        [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
        
        float samplerate;
        if ([self.defaults objectForKey:@"samplerate_value"])
            samplerate = [[self.defaults objectForKey:@"samplerate_value"] floatValue];
        
        int channels;
        if ([self.defaults objectForKey:@"channels_number"])
            channels = [[self.defaults objectForKey:@"channels_number"] doubleValue];
        
        if ([self.defaults boolForKey:@"suspend_switch"])
            [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        
        self.isRecording = YES;
        isAudioRec = YES;
        NSDictionary *recordSettings =
        [[NSDictionary alloc] initWithObjectsAndKeys:
         [NSNumber numberWithFloat:samplerate], AVSampleRateKey,
         [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
         [NSNumber numberWithInt:channels], AVNumberOfChannelsKey,
         [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
         nil];
        NSError *recorderError = nil;
        recorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:recordSettings error:&recorderError];
        [recorder prepareToRecord];
        [recorder record];
    }
    //If the app is recording, we want to stop recording
    else
    {
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1 * 60 * 60 * 24];
        [_delegate newRecordingViewController:self didAddNewRecording:_nameField.text];
        [_recorder stopRecording];
        _recorder = nil;
        [recorder stop];
        recorder = nil;
        self.isRecording = NO;
        isAudioRec = NO;
        
        if (!self.otherMediaIsPlaying) {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setActive:NO error:&error];
        }
        
        //Temporary, remove when audio merging is fixed:
        NSString *audioToDeletePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.caf",_nameField.text]];
        NSError *error = nil;
        [[[NSFileManager alloc]init]removeItemAtPath:audioToDeletePath error:&error];
        
    }
    
}


/*
 -(void)rotateVideo{
 
 NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
 
 
 
 NSString *videoURL = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4", _nameField.text]];
 
 NSURL *videoFileURL = [NSURL fileURLWithPath:videoURL];
 
 
 
 AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoFileURL options:nil];
 
 
 
 
 
 AVAssetTrack *assetVideoTrack = nil;
 
 
 
 
 
 if ([[NSFileManager defaultManager] fileExistsAtPath:videoURL]) {
 
 NSArray *assetArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
 
 if ([assetArray count] > 0)
 
 assetVideoTrack = assetArray[0];
 
 }
 
 
 
 AVMutableComposition *mixComposition = [AVMutableComposition composition];
 
 
 
 if (assetVideoTrack != nil) {
 
 AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
 
 [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:nil];
 double degrees = 0.0;
 
 if ([prefs objectForKey:@"video_orientation"])
 
 degrees = [[prefs objectForKey:@"video_orientation"] doubleValue];
 
 [compositionVideoTrack setPreferredTransform:CGAffineTransformMakeRotation(degreesToRadians(degrees))];
 
 }
 
 AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
 
 presetName:AVAssetExportPresetHighestQuality];
 
 
 
 
 
 NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@-1.mp4", _nameField.text]];
 
 NSURL    *savetUrl = [NSURL fileURLWithPath:savePath];
 
 
 
 _assetExport.outputFileType = AVFileTypeMPEG4;
 
 _assetExport.outputURL = savetUrl;
 
 _assetExport.shouldOptimizeForNetworkUse = NO;
 
 
 
 
 
 [_startStopButton setTitle:@"Setting Orientation... Please Wait..." forState:UIControlStateNormal];
 
 //_startStopButton.userInteractionEnabled = NO;
 
 
 
 
 
 
 
 [_assetExport exportAsynchronouslyWithCompletionHandler:^(void){
 
 
 
 switch(_assetExport.status)
 
 {
 
 case AVAssetExportSessionStatusCompleted:
 
 {
 
 
 
 //statusText.text = @"Export Completed";
 
 //[_startStopButton setTitle:@"Start Recording" forState:UIControlStateNormal];
 
 //_nameField.userInteractionEnabled = YES;
 
 //_startStopButton.userInteractionEnabled = YES;
 
 
 
 NSString *videoToDelete = [NSString stringWithFormat:@"%@", _nameField.text];
 
 NSString *videoToDeletePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
 
 stringByAppendingPathComponent:videoToDelete]
 
 stringByAppendingPathExtension:@"mp4"];
 
 [[[NSFileManager alloc]init]removeItemAtPath:videoToDeletePath error:NULL];
 //[self mergeAudio];
 
 
 }
 
 break;
 
 
 
 case AVAssetExportSessionStatusWaiting:
 
 {
 
 //statusText.text = @"Waiting...";
 
 [_startStopButton setTitle:@"Waiting..." forState:UIControlStateNormal];
 
 }
 
 break;
 
 case AVAssetExportSessionStatusExporting:
 
 {
 
 //statusText.text = @"Exporting...";
 
 [_startStopButton setTitle:@"Exporting..." forState:UIControlStateNormal];
 
 }
 
 break;
 
 
 
 case AVAssetExportSessionStatusFailed:
 
 {
 
 //statusText.text = @"FAILED. Trying again...";
 
 [_startStopButton setTitle:@"FAILED. Trying again..." forState:UIControlStateNormal];
 
 [self rotateVideo];
 
 
 
 }
 
 break;
 
 }
 
 
 
 
 
 
 
 
 
 
 
 
 
 }
 
 ];
 
 
 
 }
 
 */




-(void)mergeAudio{
    NSString *videoURL = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@-1.mov", _nameField.text]];
    NSURL *videoFileURL = [NSURL fileURLWithPath:videoURL];
    NSString *audioURL = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.caf", _nameField.text]];
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioURL];
    
    
    NSDictionary *options = nil;
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioFileURL options:options];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoFileURL options:options];
    
    
    
    
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    
    
    
    
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoURL]) {
        NSArray *assetArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        if ([assetArray count] > 0)
            assetVideoTrack = assetArray[0];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioURL] && [self.defaults boolForKey:@"switch_audio"]) {
        NSArray *assetArray = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
        if ([assetArray count] > 0)
            assetAudioTrack = assetArray[0];
    }
    
    //double degrees = 0.0;
    //if ([prefs objectForKey:@"video_orientation"])
    //	degrees = [[prefs objectForKey:@"video_orientation"] doubleValue];
    
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    NSError *error = nil;
    
    if (assetVideoTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
        if (assetAudioTrack != nil) [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) toDuration:audioAsset.duration];
        //[compositionVideoTrack setPreferredTransform:CGAffineTransformMakeRotation(degreesToRadians(degrees))];
    }
    
    if (assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    }
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetPassthrough];
    
    
    NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mov", _nameField.text]];
    NSURL *savetUrl = [NSURL fileURLWithPath:savePath];
    
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = savetUrl;
    _assetExport.shouldOptimizeForNetworkUse = NO;
    
    NSLog(@"NEW video saved at: %@",savetUrl);
    //[_startStopButton setTitle:@"Merging... Please Wait..." forState:UIControlStateNormal];
    //_startStopButton.userInteractionEnabled = NO;
    
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void){
        
        switch(_assetExport.status)
        {
            case AVAssetExportSessionStatusCompleted:
            {
                
                //statusText.text = @"Export Completed";
                //[_startStopButton setTitle:@"Start Recording" forState:UIControlStateNormal];
                _nameField.userInteractionEnabled = YES;
                //_startStopButton.userInteractionEnabled = YES;
                
                NSString *audioToDeletePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.caf",_nameField.text]];
                NSString *videoToDeletePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@-1.mov",_nameField.text]];
                NSError *error = nil;
                [[[NSFileManager alloc] init] removeItemAtPath:audioToDeletePath error:&error];
                [[[NSFileManager alloc] init] removeItemAtPath:videoToDeletePath error:&error];
                NSLog(@"Removed OLD video file at: %@",videoToDeletePath);
                NSLog(@"Removed OLD audio file at: %@",audioToDeletePath);
                
            }
                break;
                
            case AVAssetExportSessionStatusWaiting:
            {
                //statusText.text = @"Waiting...";
                //[_startStopButton setTitle:@"Waiting..." forState:UIControlStateNormal];
            }
                break;
            case AVAssetExportSessionStatusExporting:
            {
                //statusText.text = @"Exporting...";
                //[_startStopButton setTitle:@"Exporting..." forState:UIControlStateNormal];
            }
                break;
                
            case AVAssetExportSessionStatusFailed:
            {
                //statusText.text = @"FAILED. Trying again...";
                //[_startStopButton setTitle:@"FAILED. Trying again..." forState:UIControlStateNormal];
                [self mergeAudio];
                
            }
                break;
            case AVAssetExportSessionStatusCancelled:
            {
                
            }
                break;
            case AVAssetExportSessionStatusUnknown:
            {
                
            }
                break;
        }
        
        
        
        
        
        
    }
     ];
    
    
    
}

@end