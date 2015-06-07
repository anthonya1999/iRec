//
//  RecordingsViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "RecordingsViewController.h"
#import "UIAlertView+RSTAdditions.h"
#import "UIImage+ImageEffects.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordingsViewController ()

@end

@implementation RecordingsViewController

- (NSUserDefaults *)defaults {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return prefs;
}

- (void)viewDidLoad {
    if (_recorder) {
        //do nothing
    }
    else {
        [super viewDidLoad];
        if ([self.defaults boolForKey:@"dark_theme_switch"]) {
            [_deleteAllButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_deleteAllButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else {
            //do nothing different...
        }
        [self populateNamesArray];
        [self.tableView reloadData];
        //[self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    }
    if (_recordingNames.count == 0) {
        [_deleteAllButton setHidden:YES];
    }
    else {
        [_deleteAllButton setHidden:NO];
    }
}


//Populate the array with the files from the documents folder
- (void)populateNamesArray {
    if (_recordingNames == nil)
        _recordingNames = [[NSMutableArray alloc]init];
    else
        [_recordingNames removeAllObjects];
    for (NSString *file in [[[NSFileManager alloc]init]enumeratorAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]]) {
        if ([file hasSuffix:@".mp4"])
            [_recordingNames addObject:[file stringByDeletingPathExtension]];
    }
    
}

//Refreshes the array
- (void)refresh {
    //[self populateNamesArray];
    //[self.tableView reloadData];
    //[self.refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _recordingNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingNameCell" forIndexPath:indexPath];
    [cell.textLabel setText:_recordingNames[indexPath.row]];
    //tableView.backgroundColor = [UIColor colorWithRed:125.0f/255.0f green:125.0f/255.0f blue:125.0f/255.0f alpha:1.0f];
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *footerText = nil;
    if (_recordingNames.count == 0) {
        footerText = @"You do not currently have any recordings. Go to the \"Record\" tab to make a new one.";
    }
    else {
        footerText = @"Tap on a recording to play it. If you would like to export your recording to the Camera Roll, press the info button.";
    }
    return footerText;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = nil;
    if (_recordingNames.count >= 1) {
        headerText = nil;
    }
    else {
        headerText = @"No Recordings";
    }
    return headerText;
}

- (IBAction)deleteAllRecordings:(UIBarButtonItem *)sender {
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, 0);
    [self.view.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    viewImage = [viewImage applyBlurWithRadius:4.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
    UIImageView *blurredView = [[UIImageView alloc] initWithImage:viewImage];
    [self.view addSubview:blurredView];
    UIGraphicsEndImageContext();
    
    if (_recordingNames.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Recordings" message:@"You currently do not have any recordings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete All" message:@"Are you sure you want to delete all your recordings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1)
            {
                NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/"]];
                NSFileManager *fileMgr = [[NSFileManager alloc] init];
                NSError *error = nil;
                NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:savePath error:&error];
                if (error == nil) {
                    for (NSString *path in directoryContents) {
                        NSString *fullPath = [savePath stringByAppendingPathComponent:path];
                        BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                        if (!removeSuccess) {}}}
                else {}
                [self viewWillAppear:YES];
                [blurredView removeFromSuperview];
            }
            else  {
                [blurredView removeFromSuperview];
                [self viewWillAppear:YES];
            }
        }];
    }
}

#pragma mark - UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    /*
     UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Choose Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
     @"Export to Camera Roll", _recordingNames[indexPath.row],
     nil];
     popup.tag = 1;
     [popup showInView:[UIApplication sharedApplication].keyWindow];
     */
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(c, 0, 0);
    [self.view.layer renderInContext:c];
    UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
    viewImage = [viewImage applyBlurWithRadius:4.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
    UIImageView *blurredView = [[UIImageView alloc] initWithImage:viewImage];
    [self.view addSubview:blurredView];
    UIGraphicsEndImageContext();

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Export"
                                                    message:[NSString stringWithFormat:@"Are you sure you want to export \"%@\" to your Camera Roll?", _recordingNames[indexPath.row]]
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    _recFinalName = [NSString stringWithFormat:@"%@", _recordingNames[indexPath.row]];
    [alert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [blurredView removeFromSuperview];
        }
        if (buttonIndex == 1)
        {
            NSString *URL = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4", _recFinalName]];
            NSURL *videoURL = [NSURL fileURLWithPath:URL];
            UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, nil, NULL, NULL);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"The recording \"%@\" has successfully been saved to your Camera Roll!", _recordingNames[indexPath.row]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [blurredView removeFromSuperview];
                }
            }];
            NSLog(@"Export success!");
        }
        
    }];
    
    /*
     NSArray *objectsToShare = @[fileURL];
     UIActivityViewController *activityViewController =
     [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
     */
    /*
     NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
     activityViewController.excludedActivityTypes = excludedActivities;
     */
    /*
     [self presentViewController:activityViewController animated:YES completion:^(void){}];
     */
    /*if (fileURL)
     {
     self.controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
     self.controller.delegate = self;
     
     // Present "Open In Menu"
     [self.controller presentOpenInMenuFromRect:[tableView frame] inView:self.view animated:YES];
     }*/
    
    
    
}

- (void)export {
   
}

/*
 - (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
 
 switch (popup.tag) {
 case 1: {
 switch (buttonIndex) {
 case 0:
 [self export];
 break;
 default:
 break;
 }
 break;
 }
 default:
 break;
 }
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@.mp4", _recordingNames[indexPath.row]]];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:filePath]];
    [moviePlayerController.moviePlayer setShouldAutoplay:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:moviePlayerController  name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController.moviePlayer];
    [self.navigationController presentMoviePlayerViewControllerAnimated:moviePlayerController];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)videoFinished:(NSNotification*)aNotification {
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        [self dismissMoviePlayerViewControllerAnimated];
    }
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *videoToDelete = _recordingNames[indexPath.row];
        NSString *finalVideoToDeletePath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
                                             stringByAppendingPathComponent:videoToDelete]
                                             stringByAppendingPathExtension:@"mp4"];
        NSError *error = nil;
        [[[NSFileManager alloc] init] removeItemAtPath:finalVideoToDeletePath error:&error];
        [_recordingNames removeObjectIdenticalTo:videoToDelete];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
        [self viewWillAppear:YES];
    }
}


/*
 #pragma mark -
 #pragma mark UIBarButtonItem Actions
 
 - (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
 [self.navigationItem setLeftBarButtonItem:_doneButton animated:YES];
 [self.navigationItem setRightBarButtonItem:nil animated:YES];
 [self.tableView setEditing:YES animated:YES];
 }
 
 
 - (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
 [self.navigationItem setLeftBarButtonItem:_editButton animated:YES];
 [self.tableView setEditing:NO animated:YES];
 }
 
 */


#pragma mark - New Recording

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
        if (destinationNavController.viewControllers.count)
            [(NewRecordingViewController *)destinationNavController.viewControllers[0] setDelegate:self];
    }
}


- (void)newRecordingViewController:(NewRecordingViewController *)viewController didAddNewRecording:(NSString *)recordingName {
    [_recordingNames addObject:recordingName];
    [_recordingNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}


@end
