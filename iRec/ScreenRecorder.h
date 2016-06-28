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

typedef struct __IOSurface *IOSurfaceRef;
typedef struct __IOMobileFramebuffer *IOMobileFramebufferConnection;
typedef CGSize IOMobileFramebufferDisplaySize;
typedef	kern_return_t IOMobileFramebufferReturn, SpringBoardServicesReturn;

static IOMobileFramebufferConnection _framebufferConnection;
static IOSurfaceRef _screenSurface;
static CVPixelBufferRef _pixelBuffer;
static AVAssetWriter *_videoWriter;
static AVAssetWriterInput *_videoWriterInput;
static AVAssetWriterInputPixelBufferAdaptor *_pixelBufferAdaptor;
static dispatch_queue_t _videoQueue;
static NSLock *_pixelBufferLock;
static NSString *_videoPath;
static IOMobileFramebufferDisplaySize _screenSize;
static int _framerate, _bitrate;
static BOOL _recording;

@interface ScreenRecorder : NSObject

- (instancetype)initWithFramerate:(CGFloat)framerate bitrate:(CGFloat)bitrate;
- (void)openFramebuffer;
- (void)setupVideoRecordingObjects;
- (void)saveFrame:(CMTime)frame;
- (void)startRecording;
- (void)cleanupAndReset;
+ (void)suspendApp;

@end
