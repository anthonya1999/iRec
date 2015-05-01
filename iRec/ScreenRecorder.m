//
//  ScreenRecorder.m
//  iRec
//
//  Created by Anthony Agatiello on 2/18/15.
//
//

#import "ScreenRecorder.h"
#include <IOMobileFramebuffer/IOMobileFramebuffer.h>
#include <IOSurface/IOSurface.h>
#include <AVFoundation/AVFoundation.h>
#include <sys/time.h>

@interface ScreenRecorder () {
    IOMobileFramebufferConnection _framebufferConnection;
    IOSurfaceRef _screenSurface, _mySurface;
    CFDictionaryRef _mySurfaceAttributes;
    IOSurfaceAcceleratorRef _accelerator;
    AVAssetWriter *_videoWriter;
    AVAssetWriterInput *_videoWriterInput, *_audioWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *_pixelBufferAdaptor;
    dispatch_queue_t _videoQueue;
    NSLock *_pixelBufferLock;
    int _framerate, _bitrate;
}


@end

#define AssertSuccess(call, descriptionString) do {\
kern_return_t kernreturn = call; \
NSAssert(kernreturn==KERN_SUCCESS, @"%@ failed: %s", descriptionString, mach_error_string(kernreturn)); \
} while(0)

@implementation ScreenRecorder

/*
CGFloat degreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
};
*/

/*
-(NSString *)DeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}
*/

#pragma mark - Create Surface

- (instancetype)initWithFramerate:(CGFloat)framerate bitrate:(CGFloat)bitrate {
     if ((self = [super init])) {
         _framerate = framerate;
         _bitrate = bitrate;
         _videoQueue = dispatch_queue_create("com.agatiello.videoqueue", DISPATCH_QUEUE_SERIAL);
         _pixelBufferLock = [NSLock new];
         NSAssert(_pixelBufferLock, @"Why isn't there a pixel buffer lock?!");
        
         CFMutableDictionaryRef serviceMatching = IOServiceMatching("AppleCLCD");
         io_service_t framebufferService = IOServiceGetMatchingService(kIOMasterPortDefault, serviceMatching);
         NSAssert(framebufferService, @"Unable to get the IOService matching AppleCLCD.");
         
         IOMobileFramebufferOpen(framebufferService, mach_task_self_, 0, &_framebufferConnection);
         IOMobileFramebufferGetLayerDefaultSurface((void *)_framebufferConnection, 0, (void *)&_screenSurface);
         
         uint32_t seed = IOSurfaceGetSeed(_screenSurface);
         IOSurfaceLock(_screenSurface, kIOSurfaceLockReadOnly, &seed);
         size_t planeIndex = IOSurfaceGetPlaneCount(_screenSurface);
         size_t planeBytesPerElement = IOSurfaceGetBytesPerElementOfPlane(_screenSurface, planeIndex);
         size_t planeBytesPerRow = IOSurfaceGetBytesPerRowOfPlane(_screenSurface, planeIndex);
         size_t planeHeight = IOSurfaceGetHeightOfPlane(_screenSurface, planeIndex);
         size_t planeWidth = IOSurfaceGetWidthOfPlane(_screenSurface, planeIndex);
         size_t planeElementHeight = IOSurfaceGetElementHeightOfPlane(_screenSurface, planeIndex);
         size_t planeElementWidth = IOSurfaceGetElementWidthOfPlane(_screenSurface, planeIndex);
         size_t screenHeight = IOSurfaceGetHeight(_screenSurface);
         size_t screenWidth = IOSurfaceGetWidth(_screenSurface);
         size_t bytesPerElement = IOSurfaceGetBytesPerElement(_screenSurface);
         size_t bytesPerRow = IOSurfaceGetBytesPerRow(_screenSurface);
         size_t allocSize = IOSurfaceGetAllocSize(_screenSurface);
         size_t elementHeight = IOSurfaceGetElementHeight(_screenSurface);
         size_t elementWidth = IOSurfaceGetElementWidth(_screenSurface);
         OSType pixelFormat = IOSurfaceGetPixelFormat(_screenSurface);
         
         _mySurfaceAttributes = CFBridgingRetain(@{(__bridge NSString *)kIOSurfaceIsGlobal:             @YES,
                                                   (__bridge NSString *)kIOSurfaceBytesPerRow:          @(bytesPerRow),
                                                   (__bridge NSString *)kIOSurfaceBytesPerElement:      @(bytesPerElement),
                                                   (__bridge NSString *)kIOSurfaceWidth:                @(screenWidth),
                                                   (__bridge NSString *)kIOSurfaceHeight:               @(screenHeight),
                                                   (__bridge NSString *)kIOSurfacePixelFormat:          @(pixelFormat),
                                                   (__bridge NSString *)kIOSurfaceElementHeight:        @(elementHeight),
                                                   (__bridge NSString *)kIOSurfaceElementWidth:         @(elementWidth),
                                                   (__bridge NSString *)kIOSurfacePlaneBytesPerElement: @(planeBytesPerElement),
                                                   (__bridge NSString *)kIOSurfacePlaneBytesPerRow:     @(planeBytesPerRow),
                                                   (__bridge NSString *)kIOSurfacePlaneHeight:          @(planeHeight),
                                                   (__bridge NSString *)kIOSurfacePlaneWidth:           @(planeWidth),
                                                   (__bridge NSString *)kIOSurfacePlaneElementHeight:   @(planeElementHeight),
                                                   (__bridge NSString *)kIOSurfacePlaneElementWidth:    @(planeElementWidth),
                                                   (__bridge NSString *)kIOSurfaceAllocSize:            @(allocSize)
                                                   });
         
         _mySurface = IOSurfaceCreate(_mySurfaceAttributes);
         NSAssert(_mySurface, @"Error creating the IOSurface.");
         IOSurfaceAcceleratorCreate(kCFAllocatorDefault, 0, &_accelerator);
         IOSurfaceUnlock(_screenSurface, kIOSurfaceLockReadOnly, &seed);
     }
    return self;
}

#pragma mark - Initialize Recorder

- (void)_setupVideoRecordingObjects {
    NSAssert(_videoWriter, @"There is no video writer...WHAT?!");
    
    //CGAffineTransform playbackTransform;
    //NSAssert(error==nil, @"AVAssetWriter failed to initialise: %@", error);
    
    [_videoWriter setMovieTimeScale:_framerate];
    
    NSDictionary *compressionProperties = @{AVVideoMaxKeyFrameIntervalKey: @(_framerate),
                                            AVVideoAverageBitRateKey:      @(_bitrate*1000),
                                            AVVideoProfileLevelKey:        AVVideoProfileLevelH264HighAutoLevel
                                            };
    
    size_t screenHeight = IOSurfaceGetHeight(_screenSurface);
    size_t screenWidth = IOSurfaceGetWidth(_screenSurface);
    size_t bytesPerRow = IOSurfaceGetBytesPerRow(_screenSurface);
    OSType pixelFormat = IOSurfaceGetPixelFormat(_screenSurface);
    
    NSDictionary *outputSettings = @{AVVideoCodecKey:                 AVVideoCodecH264,
                                     AVVideoWidthKey:                 @(screenWidth),
                                     AVVideoHeightKey:                @(screenHeight),
                                     AVVideoCompressionPropertiesKey: compressionProperties
                                     };
    
    NSAssert([_videoWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo], @"Strange error: AVVideoWriter isn't accepting our output settings.");
    
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    [_videoWriterInput setMediaTimeScale:_framerate];
    NSAssert([_videoWriter canAddInput:_videoWriterInput], @"Strange error: AVVideoWriter doesn't want our input.");
    [_videoWriter addInput:_videoWriterInput];
    
    NSDictionary *sourcePixelBufferAttributes = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:      @(pixelFormat),
                                                  (__bridge NSString *)kCVPixelBufferWidthKey:                @(screenWidth),
                                                  (__bridge NSString *)kCVPixelBufferBytesPerRowAlignmentKey: @(bytesPerRow),
                                                  (__bridge NSString *)kCVPixelBufferHeightKey:               @(screenHeight)
                                                  };
    
    _pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc]initWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:sourcePixelBufferAttributes];
    [_videoWriterInput setExpectsMediaDataInRealTime:YES];
    
    /*
     playbackTransform = CGAffineTransformMakeRotation(degreesToRadians(90));
     _videoWriterInput.transform = playbackTransform;
     
     
     
     AudioChannelLayout acl;
     bzero(&acl, sizeof(acl));
     acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
     
     NSDictionary*  audioOutputSettings;
     
     audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
     [ NSNumber numberWithInt: 2 ], AVNumberOfChannelsKey,
     [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
     [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
     [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
     nil];
     
     
     _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
     
     _audioWriterInput.expectsMediaDataInRealTime = YES;
     
     //\Add inputs to Write
     NSAssert([_videoWriter canAddInput:_audioWriterInput], @"Cannot write to this type of audio input" );
     NSAssert([_videoWriter canAddInput:_audioWriterInput], @"Cannot write to this type of video input" );
     
     [_videoWriter addInput:_audioWriterInput];
     */
    
    [_videoWriter addInput:_videoWriterInput];
    [_videoWriter startWriting];
    [_videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //NSAssert(_pixelBufferAdaptor.pixelBufferPool, @"There's no pixel buffer pool? Something has gone horribly wrong...");
}

#pragma mark - Start Recording

- (void)startRecording {
    NSError *error = nil;
    _videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_videoPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    
    //Better safe than sorry
    NSAssert(_videoPath, @"You're telling me to record but not where to put the result. How am I supposed to know where to put this frickin' video? :(");
    NSAssert(!_recording, @"Trying to start recording, but we're already recording?!!?!");
    
    [self _setupVideoRecordingObjects];
    _recording = YES;
    
    NSLog(@"Recorder started.");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        struct timeval currentTime, lastSnapshot;
        lastSnapshot.tv_sec = lastSnapshot.tv_usec = 0;
        
        unsigned int frame = 0;
        int msBeforeNextCapture = 850 / _framerate;
        while (_recording) {
            gettimeofday(&currentTime, NULL);
            currentTime.tv_usec /= 850;
            unsigned long long delta = ((850*currentTime.tv_sec+currentTime.tv_usec) - (850*lastSnapshot.tv_sec+lastSnapshot.tv_usec));
            if (delta >= msBeforeNextCapture) {
                CMTime presentTime = CMTimeMake(frame, _framerate);
                [self _saveFrame:presentTime];
                frame++;
                lastSnapshot = currentTime;
            }
        }
        dispatch_async(_videoQueue, ^{
            [self _recordingDone];
        });
    });
}

#pragma mark - Capture Frame

- (void)_saveFrame:(CMTime)frame {
    uint32_t seed = IOSurfaceGetSeed(_screenSurface);
    IOSurfaceLock(_screenSurface, kIOSurfaceLockReadOnly, &seed);
    IOSurfaceAcceleratorTransferSurface(_accelerator, _screenSurface, _mySurface, _mySurfaceAttributes, NULL);
    IOSurfaceUnlock(_screenSurface, kIOSurfaceLockReadOnly, &seed);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!_pixelBufferAdaptor.pixelBufferPool) {
            NSLog(@"Skipping frame: %lld", frame.value);
            return;
        }
        
        static CVPixelBufferRef pixelBuffer = NULL;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSAssert(_pixelBufferAdaptor.pixelBufferPool, @"The pixel buffer pool is returning NULL (nothing). Please ensure there is one before saving a frame!");
            [_pixelBufferLock lock];
            CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _pixelBufferAdaptor.pixelBufferPool, &pixelBuffer);
            [_pixelBufferLock unlock];
            NSAssert(pixelBuffer, @"There's no pixel buffer?! AT ALL?!!! Something's messed up.");
        });
        
        CVOptionFlags optionFlags = 0;
        CVPixelBufferLockBaseAddress(pixelBuffer, optionFlags);
        size_t allocSize = IOSurfaceGetAllocSize(_mySurface);
        void *baseAddress = IOSurfaceGetBaseAddress(_mySurface);
        void *pixelBufferBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        NSAssert(baseAddress, @"IOSurface can't get the base address? Check to see if the framework is functioning properly!");
        NSAssert(pixelBufferBaseAddress, @"Be sure to check the pixel buffer, it cannot get the base address!");
        memcpy(pixelBufferBaseAddress, baseAddress, allocSize);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, optionFlags);
        
        dispatch_async(_videoQueue, ^{
            while(!_videoWriterInput.readyForMoreMediaData)
                usleep(850);
                [_pixelBufferLock lock];
                [_pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:frame];
                [_pixelBufferLock unlock];
        });
    });
}

#pragma mark - Stop, Finalize Recorder, and Release Objects

- (void)stopRecording {
    NSLog(@"Recorder stopped.");
    [self setRecording:NO];
}

- (void)_recordingDone {
    [_videoWriterInput markAsFinished];
    [_videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"Recording saved at path: %@",_videoPath);
        _videoPath = nil;
        _videoQueue = nil;
        _videoWriter = nil;
        _pixelBufferLock = nil;
        _videoWriterInput = nil;
        _pixelBufferAdaptor = nil;
        CFRelease(_mySurface);
        _mySurface = NULL;
        CFRelease(_screenSurface);
        _screenSurface = NULL;
        CFRelease(_accelerator);
        _accelerator = NULL;
        CFRelease(_mySurfaceAttributes);
        _mySurfaceAttributes = nil;
        CFRelease((void *)_framebufferConnection);
        _framebufferConnection = nil;
    }];
}

/*

#pragma mark - Cleanup

- (void)dealloc {
    CFRelease(_accelerator);
    CFRelease(_mySurface);
    CFRelease(_mySurfaceAttributes);
    CFRelease((void *)_framebufferConnection);
}
 
*/

@end
