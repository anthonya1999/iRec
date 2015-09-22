//
//  ScreenRecorder.h
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Private.h"

@interface ScreenRecorder : NSObject

@end

@interface ScreenRecorder (Private)

- (instancetype)initWithFramerate:(CGFloat)framerate bitrate:(CGFloat)bitrate;

- (void)openFramebuffer;
- (void)setupVideoRecordingObjects;
- (void)saveFrame:(CMTime)frame;
- (void)startRecording;
- (void)cleanupAndReset;

@end