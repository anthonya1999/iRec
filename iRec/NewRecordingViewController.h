//
//  NewRecordingViewController.h
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@class ScreenRecorder;
@protocol NewRecordingViewControllerDelegate;

@interface NewRecordingViewController : UITableViewController <UIAlertViewDelegate, AVAudioRecorderDelegate> {
    ScreenRecorder *_recorder;
    IBOutlet UITextField *_nameField;
    IBOutlet UIButton *_startStopButton;
    AVAudioRecorder *recorder;
    AVAudioSession *session;
    NSTimer *spaceTimer;
    BOOL isRecording;
    IBOutlet UINavigationItem *navigationTextbar;
    AVCaptureSession *sessionTwo;
}

@property (nonatomic) BOOL isRecording;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButtonOutlet;
@property (weak, nonatomic) id<NewRecordingViewControllerDelegate> delegate;

@end

@protocol NewRecordingViewControllerDelegate <NSObject>
- (void)newRecordingViewController:(NewRecordingViewController *)viewController didAddNewRecording:(NSString *)recordingName;

@end
