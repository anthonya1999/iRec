//
//  ScreenRecorder.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "ScreenRecorder.h"
#include <sys/time.h>
#include <dlfcn.h>

@implementation ScreenRecorder

#pragma mark - Initialization

- (instancetype)initWithFramerate:(CGFloat)framerate bitrate:(CGFloat)bitrate {
     if ((self = [super init])) {
         _framerate = framerate;
         _bitrate = bitrate;
         _videoQueue = dispatch_queue_create("video_queue", DISPATCH_QUEUE_SERIAL);
         NSAssert(_videoQueue, @"Unable to create video queue.");
         _pixelBufferLock = [[NSLock alloc] init];
         NSAssert(_pixelBufferLock, @"Why isn't there a pixel buffer lock?!");
    }
    return self;
}

#pragma mark - Open Framebuffer

- (void)openFramebuffer {
    void *IOMobileFramebuffer = dlopen("/System/Library/PrivateFrameworks/IOMobileFramebuffer.framework/IOMobileFramebuffer", RTLD_LAZY);
    NSParameterAssert(IOMobileFramebuffer);
    
    IOMobileFramebufferReturn (*IOMobileFramebufferGetMainDisplay)(IOMobileFramebufferConnection *connection) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferGetMainDisplay");
    NSParameterAssert(IOMobileFramebufferGetMainDisplay);
    IOMobileFramebufferReturn (*IOMobileFramebufferGetDisplaySize)(IOMobileFramebufferConnection connection, CGSize *size) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferGetDisplaySize");
    NSParameterAssert(IOMobileFramebufferGetDisplaySize);
    IOMobileFramebufferReturn (*IOMobileFramebufferGetLayerDefaultSurface)(IOMobileFramebufferConnection connection, int surface, IOSurfaceRef *buffer) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferGetLayerDefaultSurface");
    NSParameterAssert(IOMobileFramebufferGetLayerDefaultSurface);
    
    IOMobileFramebufferGetMainDisplay(&_framebufferConnection);
    IOMobileFramebufferGetDisplaySize(_framebufferConnection, &_screenSize);
    IOMobileFramebufferGetLayerDefaultSurface(_framebufferConnection, 0, &_screenSurface);
    
    CFRetain(_framebufferConnection);
    CFRetain(_screenSurface);
    
    dlclose(IOMobileFramebuffer);
}

#pragma mark - Initialize Recorder

- (void)setupVideoRecordingObjects {
    NSAssert(_videoWriter, @"There is no video writer...WHAT?!");
    [_videoWriter setMovieTimeScale:_framerate];
    
    NSDictionary *compressionProperties = @{AVVideoAverageBitRateKey:      @(_bitrate * 1000),
                                            AVVideoMaxKeyFrameIntervalKey: @(_framerate),
                                            AVVideoProfileLevelKey:        AVVideoProfileLevelH264HighAutoLevel};
    
    NSDictionary *outputSettings = @{AVVideoCompressionPropertiesKey: compressionProperties,
                                     AVVideoCodecKey:                 AVVideoCodecH264,
                                     AVVideoWidthKey:                 @(_screenSize.width),
                                     AVVideoHeightKey:                @(_screenSize.height)};
    
    NSAssert([_videoWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo], @"Strange error: AVVideoWriter isn't accepting our output settings.");
    
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    [_videoWriterInput setMediaTimeScale:_framerate];
    NSAssert([_videoWriter canAddInput:_videoWriterInput], @"Strange error: AVVideoWriter doesn't want our input.");
    [_videoWriter addInput:_videoWriterInput];
    
    _pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:nil];
    [_videoWriterInput setExpectsMediaDataInRealTime:YES];
    
    [_videoWriter addInput:_videoWriterInput];
    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
}

#pragma mark - Start Recording

- (void)startRecording {
    NSError *error = nil;
    _videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_videoPath] fileType:AVFileTypeMPEG4 error:&error];
    
    //Better safe than sorry
    NSAssert(_videoPath, @"You're telling me to record but not where to put the result. How am I supposed to know where to put this frickin' video? :(");
    NSAssert(!_recording, @"Trying to start recording, but we're already recording?!!?!");
    
    [self openFramebuffer];
    NSAssert(_screenSurface != NULL, @"It seems as if the framebuffer was not opened!");
    
    [self setupVideoRecordingObjects];
    _recording = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        struct timeval currentTime, lastSnapshot;
        lastSnapshot.tv_sec = lastSnapshot.tv_usec = 0;
        unsigned int frame = 0;
        int msBeforeNextCapture = 1000 / _framerate;
        
        while (_recording) {
            gettimeofday(&currentTime, NULL);
            currentTime.tv_usec /= 1000;
            unsigned long long delta = ((1000 * currentTime.tv_sec + currentTime.tv_usec) - (1000 * lastSnapshot.tv_sec + lastSnapshot.tv_usec));
            
            if (delta >= msBeforeNextCapture) {
                CMTime presentTime = CMTimeMake(frame, _framerate);
                [self saveFrame:presentTime];
                frame++;
                lastSnapshot = currentTime;
            }
        }
        dispatch_async(_videoQueue, ^{
            [_videoWriterInput markAsFinished];
            [_videoWriter finishWritingWithCompletionHandler:^{
                [self cleanupAndReset];
            }];
        });
    });
}

#pragma mark - Capture Frame

- (void)saveFrame:(CMTime)frame {
    void *CoreVideo = dlopen("/System/Library/Frameworks/CoreVideo.framework/CoreVideo", RTLD_LAZY);
    NSParameterAssert(CoreVideo);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_pixelBuffer) {
            CVReturn (*CVPixelBufferCreateWithIOSurface)(CFAllocatorRef allocator, IOSurfaceRef buffer, CFDictionaryRef pixelBufferAttributes, CVPixelBufferRef *pixelBufferOut) = dlsym(CoreVideo, "CVPixelBufferCreateWithIOSurface");
            NSParameterAssert(CVPixelBufferCreateWithIOSurface);
            [_pixelBufferLock lock];
            CVPixelBufferCreateWithIOSurface(kCFAllocatorDefault, _screenSurface, NULL, &_pixelBuffer);
            [_pixelBufferLock unlock];
            NSAssert(_pixelBuffer, @"Why isn't the pixel buffer created?!");
            CVPixelBufferRetain(_pixelBuffer);
        }
        
        dispatch_async(_videoQueue, ^{
            while(!_videoWriterInput.readyForMoreMediaData) {
                usleep(1000);
            }
            [_pixelBufferLock lock];
            [_pixelBufferAdaptor appendPixelBuffer:_pixelBuffer withPresentationTime:frame];
            [_pixelBufferLock unlock];
        });
    });
    
    dlclose(CoreVideo);
}

#pragma mark - Cleanup & Reset

- (void)cleanupAndReset {
    CFRelease(_screenSurface);
    _screenSurface = NULL;
    CFRelease(_framebufferConnection);
    _framebufferConnection = NULL;
    CVPixelBufferRelease(_pixelBuffer);
    _pixelBuffer = NULL;
    _videoQueue = NULL;
    _videoWriter = nil;
    _videoWriterInput = nil;
    _pixelBufferLock = nil;
    _pixelBufferAdaptor = nil;
    _videoPath = nil;
}

@end
