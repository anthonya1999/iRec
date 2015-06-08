//
//  RecordingsViewController.h
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "NewRecordingViewController.h"
#import "ScreenRecorder.h"
#import <UIKit/UIKit.h>

@interface RecordingsViewController : UITableViewController <NewRecordingViewControllerDelegate, UIDocumentInteractionControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    NSMutableArray *_recordingNames;
    NSString *_recFinalName;
    IBOutlet UIButton *_deleteAllButton;
    ScreenRecorder *_recorder;
}

//@property (nonatomic, strong) UIDocumentInteractionController *controller;
//@property (nonatomic, strong) CLLocationManager *locationManager;
//@property (nonatomic, strong) NSMutableArray *locations;

@end
