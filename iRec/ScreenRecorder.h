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

@interface ScreenRecorder : NSObject

__BEGIN_DECLS

typedef struct __IOSurface *IOSurfaceRef;
typedef struct __IOSurfaceAccelerator *IOSurfaceAcceleratorRef;
typedef void *IOMobileFramebufferConnection;

enum {
    kIOServiceInteractionAllowed = 0x00000001
};

enum {
    kIOSurfaceLockReadOnly  = 0x00000001,
    kIOSurfaceLockAvoidSync = 0x00000002
};

__END_DECLS

- (instancetype)initWithFramerate:(CGFloat)framerate bitrate:(CGFloat)bitrate;
- (int)openFramebuffer;
- (IOSurfaceRef)createScreenSurface;
- (void)setupVideoRecordingObjects;
- (void)saveFrame:(CMTime)frame;
- (void)recordingDone;

- (void)startRecording;
- (void)stopRecording;

- (NSInteger)screenWidth;
- (NSInteger)screenHeight;

@property (nonatomic) BOOL recording;
@property (copy, nonatomic) NSString *videoPath;

@end