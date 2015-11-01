//
//  RecordingsViewController.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "RecordingsViewController.h"
#import "UIAlertView+RSTAdditions.h"
#import "FXBlurView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Private.h"

@implementation RecordingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_recording) {
        [self populateNamesArray];
    }
    [self.tableView reloadData];
    if (_recordingNames.count == 0) {
        [_deleteAllButton setHidden:YES];
    }
    else {
        [_deleteAllButton setHidden:NO];
    }
}

//Populate the array with the files from the documents folder
- (void)populateNamesArray {
    if (_recordingNames == nil) {
        _recordingNames = [[NSMutableArray alloc] init];
    }
    else {
        [_recordingNames removeAllObjects];
    }
    for (NSString *file in [[[NSFileManager alloc] init] enumeratorAtPath:documentsDirectory]) {
        if ([file hasSuffix:@".mp4"])
            [_recordingNames addObject:[file stringByDeletingPathExtension]];
    }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([userDefaults boolForKey:@"thumbnails_switch"]) {
        return 120;
    }
    else {
        return 44;
    }
}

- (UIImage *)thumbnailFromVideoAtURL:(NSURL *)contentURL {
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:contentURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime time = CMTimeMake([videoAsset duration].timescale, [videoAsset duration].timescale / 2);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:nil error:&error];
    
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return thumbnailImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingNameCell" forIndexPath:indexPath];
    
    if ([userDefaults boolForKey:@"thumbnails_switch"]) {
        UIImageView *thumbnailImageView = [[UIImageView alloc] initWithImage:[self thumbnailFromVideoAtURL:[NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", _recordingNames[indexPath.row]]]]]];
        cell.textLabel.font = [cell.textLabel.font fontWithSize:18];
        
        if (!UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [cell.textLabel setText:[NSString stringWithFormat:@"            %@", _recordingNames[indexPath.row]]];
            [thumbnailImageView setFrame:CGRectMake(-18, 5, 110, 110)];
        }
        else {
            [cell.textLabel setText:[NSString stringWithFormat:@"               %@", _recordingNames[indexPath.row]]];
            [thumbnailImageView setFrame:CGRectMake(-7, 5, 110, 110)];
        }
        
        thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:thumbnailImageView];
    }
    
    else {
        [cell.textLabel setText:_recordingNames[indexPath.row]];
        cell.textLabel.font = [cell.textLabel.font fontWithSize:16];
    }
    
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
    FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height * 4)];
    [blurView setDynamic:YES];
    blurView.tintColor = [UIColor clearColor];
    blurView.blurRadius = 8;
    [self.view addSubview:blurView];
    
    if (_recordingNames.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Recordings" message:@"You currently do not have any recordings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete All" message:@"Are you sure you want to delete all your recordings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (_recording) {
                    UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must stop recording before you delete all of your current recordings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [failAlert showWithSelectionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [blurView removeFromSuperview];
                    }];
                }
                else {
                    NSFileManager *fileMgr = [NSFileManager defaultManager];
                    NSError *error = nil;
                    NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
                    for (NSString *path in directoryContents) {
                        NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                        [fileMgr removeItemAtPath:fullPath error:&error];
                    }
                }
                [blurView removeFromSuperview];
            }
            else {
                [blurView removeFromSuperview];
            }
            [self viewWillAppear:YES];
        }];
    }
}

#pragma mark - UITableViewDelegate Methods

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *URL = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", _recordingNames[indexPath.row]]];
    NSURL *fileURL = [NSURL fileURLWithPath:URL];
     NSArray *objectsToShare = @[fileURL];
     UIActivityViewController *activityViewController =
     [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
 
     NSArray *excludedActivities = @[UIActivityTypePostToWeibo,UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
     activityViewController.excludedActivityTypes = excludedActivities;
 
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        activityViewController.popoverPresentationController.sourceView = self.view;
    }
     [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", _recordingNames[indexPath.row]]];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:filePath]];
        [moviePlayerController.moviePlayer setShouldAutoplay:NO];
        [[NSNotificationCenter defaultCenter] removeObserver:moviePlayerController name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController.moviePlayer];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController.moviePlayer];
        [self.navigationController presentMoviePlayerViewControllerAnimated:moviePlayerController];
    }
    
    else {
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
        playerViewController.player = [AVPlayer playerWithPlayerItem:item];
        [self presentViewController:playerViewController animated:NO completion:nil];
    }
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
        NSString *finalVideoToDeletePath = [[[documentsDirectory stringByAppendingPathComponent:@""] stringByAppendingPathComponent:videoToDelete] stringByAppendingPathExtension:@"mp4"];
        NSError *error = nil;
        [[[NSFileManager alloc] init] removeItemAtPath:finalVideoToDeletePath error:&error];
        [_recordingNames removeObjectIdenticalTo:videoToDelete];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
        [self viewWillAppear:YES];
    }
}

- (void)newRecordingViewController:(NewRecordingViewController *)viewController didAddNewRecording:(NSString *)recordingName {
    [_recordingNames addObject:recordingName];
    [_recordingNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

@end
