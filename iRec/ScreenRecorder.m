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
#include <mach/mach.h>

@implementation ScreenRecorder

#pragma mark - Initialization

- (instancetype)initWithFramerate:(CGFloat)framerate bitrate:(CGFloat)bitrate {
     if ((self = [super init])) {
         _framerate = framerate;
         _bitrate = bitrate;
         _videoQueue = dispatch_queue_create("video_queue", DISPATCH_QUEUE_SERIAL);
         NSAssert(_videoQueue, @"Unable to create video queue.");
         _pixelBufferLock = [NSLock new];
         NSAssert(_pixelBufferLock, @"Why isn't there a pixel buffer lock?!");
         
         [self openFramebuffer];
         
         _IOSurface = dlopen("/System/Library/PrivateFrameworks/IOSurface.framework/IOSurface", RTLD_NOW);
         NSParameterAssert(_IOSurface);

         size_t (*IOSurfaceGetAllocSize)(IOSurfaceRef buffer) = dlsym(_IOSurface, "IOSurfaceGetAllocSize");
         NSParameterAssert(IOSurfaceGetAllocSize);
         size_t (*IOSurfaceGetBytesPerRow)(IOSurfaceRef buffer) = dlsym(_IOSurface, "IOSurfaceGetBytesPerRow");
         NSParameterAssert(IOSurfaceGetBytesPerRow);
         _allocSize = IOSurfaceGetAllocSize(_screenSurface);
         _bytesPerRow = IOSurfaceGetBytesPerRow(_screenSurface);
    }
    return self;
}

#pragma mark - Open Framebuffer

- (void)openFramebuffer {
    void *IOKit = dlopen("/System/Library/Frameworks/IOKit.framework/IOKit", RTLD_NOW);
    NSParameterAssert(IOKit);
    void *IOMobileFramebuffer = dlopen("/System/Library/PrivateFrameworks/IOMobileFramebuffer.framework/IOMobileFramebuffer", RTLD_NOW);
    NSParameterAssert(IOMobileFramebuffer);
    
    CFMutableDictionaryRef (*IOServiceMatching)(const char *name) = dlsym(IOKit, "IOServiceMatching");
    NSParameterAssert(IOServiceMatching);
    mach_port_t (*IOServiceGetMatchingService)(void *masterPort, CFDictionaryRef matching) = dlsym(IOKit, "IOServiceGetMatchingService");
    NSParameterAssert(IOServiceGetMatchingService);
    
    mach_port_t serviceMatching = IOServiceGetMatchingService(NULL, IOServiceMatching("AppleCLCD"));
    if (!serviceMatching)
        serviceMatching = IOServiceGetMatchingService(NULL, IOServiceMatching("AppleH1CLCD"));
    if (!serviceMatching)
        serviceMatching = IOServiceGetMatchingService(NULL, IOServiceMatching("AppleM2CLCD"));
    if (!serviceMatching)
        serviceMatching = IOServiceGetMatchingService(NULL, IOServiceMatching("AppleRGBOUT"));
    if (!serviceMatching)
        serviceMatching = IOServiceGetMatchingService(NULL, IOServiceMatching("AppleMX31IPU"));
    if (!serviceMatching)
        serviceMatching = IOServiceGetMatchingService(NULL, IOServiceMatching("AppleMobileCLCD"));
    if (!serviceMatching)
        serviceMatching = IOServiceGetMatchingService(NULL, IOServiceMatching("IOMobileFramebuffer"));
    
    NSAssert(serviceMatching, @"Unable to get IOService matching display types.");
    
    mach_port_t *mach_task_self_ = dlsym(IOKit, "mach_task_self_");
    NSParameterAssert(*mach_task_self_);
    kern_return_t (*IOServiceAuthorize)(mach_port_t service, uint32_t options) = dlsym(IOKit, "IOServiceAuthorize");
    NSParameterAssert(IOServiceAuthorize);
    kern_return_t (*IOMobileFramebufferOpen)(mach_port_t service, task_port_t owningTask, unsigned int type, IOMobileFramebufferConnection *connection) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferOpen");
    NSParameterAssert(IOMobileFramebufferOpen);
    kern_return_t (*IOMobileFramebufferGetLayerDefaultSurface)(IOMobileFramebufferConnection connection, int surface, IOSurfaceRef *buffer) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferGetLayerDefaultSurface");
    NSParameterAssert(IOMobileFramebufferGetLayerDefaultSurface);
    kern_return_t (*IOMobileFramebufferSwapBegin)(IOMobileFramebufferConnection, int *token) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferSwapBegin");
    NSParameterAssert(IOMobileFramebufferSwapBegin);
    kern_return_t (*IOMobileFramebufferSwapSetLayer)(IOMobileFramebufferConnection connection, int layerid, IOSurfaceRef buffer) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferSwapSetLayer");
    NSParameterAssert(IOMobileFramebufferSwapSetLayer);
    kern_return_t (*IOMobileFramebufferSwapEnd)(IOMobileFramebufferConnection connection) = dlsym(IOMobileFramebuffer, "IOMobileFramebufferSwapEnd");
    NSParameterAssert(IOMobileFramebufferSwapEnd);
    
    IOServiceAuthorize(serviceMatching, kIOServiceInteractionAllowed);
    
    IOMobileFramebufferSwapBegin(_framebufferConnection, NULL);
    IOMobileFramebufferSwapSetLayer(_framebufferConnection, 0, _screenSurface);
    IOMobileFramebufferSwapEnd(_framebufferConnection);
    
    IOMobileFramebufferOpen(serviceMatching, *mach_task_self_, 0, &_framebufferConnection);
    IOMobileFramebufferGetLayerDefaultSurface(_framebufferConnection, 0, &_screenSurface);
    
    dlclose(IOKit);
    dlclose(IOMobileFramebuffer);
}

#pragma mark - Create Surface

- (IOSurfaceRef)createScreenSurface {
    size_t (*IOSurfaceGetBytesPerElement)(IOSurfaceRef buffer) = dlsym(_IOSurface, "IOSurfaceGetBytesPerElement");
    NSParameterAssert(IOSurfaceGetBytesPerElement);
    size_t bytesPerElement = IOSurfaceGetBytesPerElement(_screenSurface);
    
    OSType (*IOSurfaceGetTileFormat)(IOSurfaceRef buffer) = dlsym(_IOSurface, "IOSurfaceGetTileFormat");
    NSParameterAssert(IOSurfaceGetTileFormat);
    OSType tileFormat = IOSurfaceGetTileFormat(_screenSurface);
    
    const CFStringRef *kIOSurfaceIsGlobal = dlsym(_IOSurface, "kIOSurfaceIsGlobal");
    NSParameterAssert(*kIOSurfaceIsGlobal);
    const CFStringRef *kIOSurfaceBytesPerElement = dlsym(_IOSurface, "kIOSurfaceBytesPerElement");
    NSParameterAssert(*kIOSurfaceBytesPerElement);
    const CFStringRef *kIOSurfaceAllocSize = dlsym(_IOSurface, "kIOSurfaceAllocSize");
    NSParameterAssert(*kIOSurfaceAllocSize);
    const CFStringRef *kIOSurfaceBytesPerRow = dlsym(_IOSurface, "kIOSurfaceBytesPerRow");
    NSParameterAssert(*kIOSurfaceBytesPerRow);
    const CFStringRef *kIOSurfaceWidth = dlsym(_IOSurface, "kIOSurfaceWidth");
    NSParameterAssert(*kIOSurfaceWidth);
    const CFStringRef *kIOSurfaceHeight = dlsym(_IOSurface, "kIOSurfaceHeight");
    NSParameterAssert(*kIOSurfaceHeight);
    const CFStringRef *kIOSurfacePixelFormat = dlsym(_IOSurface, "kIOSurfacePixelFormat");
    NSParameterAssert(*kIOSurfacePixelFormat);
    const CFStringRef *kIOSurfaceBufferTileFormat = dlsym(_IOSurface, "kIOSurfaceBufferTileFormat");
    NSParameterAssert(*kIOSurfaceBufferTileFormat);
    const CFStringRef *kIOSurfaceCacheMode = dlsym(_IOSurface, "kIOSurfaceCacheMode");
    NSParameterAssert(*kIOSurfaceCacheMode);
    
    _properties = CFBridgingRetain(@{(__bridge NSString *)*kIOSurfaceIsGlobal:         @YES,
                                     (__bridge NSString *)*kIOSurfaceBytesPerElement:  @(bytesPerElement),
                                     (__bridge NSString *)*kIOSurfaceAllocSize:        @(_allocSize),
                                     (__bridge NSString *)*kIOSurfaceBytesPerRow:      @(_bytesPerRow),
                                     (__bridge NSString *)*kIOSurfaceWidth:            @(self.screenWidth),
                                     (__bridge NSString *)*kIOSurfaceHeight:           @(self.screenHeight),
                                     (__bridge NSString *)*kIOSurfacePixelFormat:      @(kCVPixelFormatType_32BGRA),
                                     (__bridge NSString *)*kIOSurfaceBufferTileFormat: @(tileFormat),
                                     (__bridge NSString *)*kIOSurfaceCacheMode:        @(kIOMapInhibitCache)
                                     });
    
    kern_return_t (*IOSurfaceAcceleratorCreate)(CFAllocatorRef allocator, uint32_t type, IOSurfaceAcceleratorRef *outAccelerator) = dlsym(_IOSurface, "IOSurfaceAcceleratorCreate");
    NSParameterAssert(IOSurfaceAcceleratorCreate);
    IOSurfaceRef (*IOSurfaceCreate)(CFDictionaryRef properties) = dlsym(_IOSurface, "IOSurfaceCreate");
    NSParameterAssert(IOSurfaceCreate);
    
    IOSurfaceAcceleratorCreate(kCFAllocatorDefault, 0, &_accelerator);
    return IOSurfaceCreate(_properties);
}

#pragma mark - Initialize Recorder

- (void)setupVideoRecordingObjects {
    NSAssert(_videoWriter, @"There is no video writer...WHAT?!");
    
    //CGAffineTransform playbackTransform;
    //NSAssert(error==nil, @"AVAssetWriter failed to initialize: %@", error);

    [_videoWriter setMovieTimeScale:_framerate];
    
    NSMutableDictionary * compressionProperties = [NSMutableDictionary dictionary];
    [compressionProperties setObject: [NSNumber numberWithInt:_bitrate * 1000] forKey: AVVideoAverageBitRateKey];
    [compressionProperties setObject: [NSNumber numberWithInt:_framerate] forKey: AVVideoMaxKeyFrameIntervalKey];
    [compressionProperties setObject: AVVideoProfileLevelH264HighAutoLevel forKey: AVVideoProfileLevelKey];
    
    NSMutableDictionary *outputSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           AVVideoCodecH264, AVVideoCodecKey,
                                           [NSNumber numberWithUnsignedLong:self.screenWidth], AVVideoWidthKey,
                                           [NSNumber numberWithUnsignedLong:self.screenHeight], AVVideoHeightKey,
                                           compressionProperties, AVVideoCompressionPropertiesKey,
                                           nil];
    
    NSAssert([_videoWriter canApplyOutputSettings:outputSettings forMediaType:AVMediaTypeVideo], @"Strange error: AVVideoWriter isn't accepting our output settings.");
    
    _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    [_videoWriterInput setMediaTimeScale:_framerate];
    NSAssert([_videoWriter canAddInput:_videoWriterInput], @"Strange error: AVVideoWriter doesn't want our input.");
    [_videoWriter addInput:_videoWriterInput];
    
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                      [NSNumber numberWithUnsignedLong:self.screenWidth], kCVPixelBufferWidthKey,
                                      [NSNumber numberWithUnsignedLong:self.screenHeight], kCVPixelBufferHeightKey,
                                      [NSNumber numberWithUnsignedLong:_bytesPerRow], kCVPixelBufferBytesPerRowAlignmentKey,
                                      kCFAllocatorDefault, kCVPixelBufferMemoryAllocatorKey,
                                      nil];
    
    _pixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc]initWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:bufferAttributes];
    [_videoWriterInput setExpectsMediaDataInRealTime:YES];
    
    /*
     playbackTransform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(90));
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
    _videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_videoPath] fileType:AVFileTypeMPEG4 error:&error];
    
    //Better safe than sorry
    NSAssert(_videoPath, @"You're telling me to record but not where to put the result. How am I supposed to know where to put this frickin' video? :(");
    NSAssert(!_recording, @"Trying to start recording, but we're already recording?!!?!");
    
    [self setupVideoRecordingObjects];
    _recording = YES;
    
    NSLog(@"Recorder started.");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            [self recordingDone];
        });
    });
}

#pragma mark - Capture Frame

- (void)saveFrame:(CMTime)frame {
    if (!_mySurface) {
        _mySurface = [self createScreenSurface];
        NSAssert(_mySurface, @"Error creating the IOSurface.");
    }
    
    uint32_t (*IOSurfaceGetSeed)(IOSurfaceRef buffer) = dlsym(_IOSurface, "IOSurfaceGetSeed");
    NSParameterAssert(IOSurfaceGetSeed);
    kern_return_t (*IOSurfaceLock)(IOSurfaceRef buffer, uint32_t lockOptions, uint32_t *seed) = dlsym(_IOSurface, "IOSurfaceLock");
    NSParameterAssert(IOSurfaceLock);
    kern_return_t (*IOSurfaceAcceleratorTransferSurface)(IOSurfaceAcceleratorRef accelerator, IOSurfaceRef sourceSurface, IOSurfaceRef destSurface, CFDictionaryRef properties, void *unknown) = dlsym(_IOSurface, "IOSurfaceAcceleratorTransferSurface");
    NSParameterAssert(IOSurfaceAcceleratorTransferSurface);
    kern_return_t (*IOSurfaceUnlock)(IOSurfaceRef buffer, uint32_t lockOptions, uint32_t *seed) = dlsym(_IOSurface, "IOSurfaceUnlock");
    NSParameterAssert(IOSurfaceUnlock);
    void *(*IOSurfaceGetBaseAddress)(IOSurfaceRef buffer) = dlsym(_IOSurface, "IOSurfaceGetBaseAddress");
    NSParameterAssert(IOSurfaceGetBaseAddress);
    
    uint32_t seed1 = IOSurfaceGetSeed(_screenSurface);
    IOSurfaceLock(_screenSurface, kIOSurfaceLockReadOnly, &seed1);
    IOSurfaceAcceleratorTransferSurface(_accelerator, _screenSurface, _mySurface, _properties, NULL);
    IOSurfaceUnlock(_screenSurface, kIOSurfaceLockReadOnly, &seed1);

    static CVPixelBufferRef pixelBuffer = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [_pixelBufferLock lock];
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _pixelBufferAdaptor.pixelBufferPool, &pixelBuffer);
        NSAssert(pixelBuffer, @"Why isn't the pixel buffer created?!");
        [_pixelBufferLock unlock];
    });
   
    uint32_t seed2 = IOSurfaceGetSeed(_mySurface);
    IOSurfaceLock(_mySurface, kIOSurfaceLockReadOnly, &seed2);
    void *baseAddress = IOSurfaceGetBaseAddress(_mySurface);
    NSAssert(baseAddress, @"Unable to get base address from IOSurface.");
    IOSurfaceUnlock(_mySurface, kIOSurfaceLockReadOnly, &seed2);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *pixelBufferBaseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    NSAssert(pixelBufferBaseAddress, @"Unable to get base address from pixel buffer.");
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    memmove(pixelBufferBaseAddress, baseAddress, _allocSize);
    
    dispatch_async(_videoQueue, ^{
        while(!_videoWriterInput.readyForMoreMediaData)
            usleep(1000);
            [_pixelBufferLock lock];
            [_pixelBufferAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:frame];
            [_pixelBufferLock unlock];
    });
}

#pragma mark - Stop, Finalize Recorder, and Release Objects

- (void)stopRecording {
    NSLog(@"Recorder stopped.");
    [self setRecording:NO];
}

- (void)recordingDone {
    [_videoWriterInput markAsFinished];
    [_videoWriter finishWritingWithCompletionHandler:^{
        dlclose(_IOSurface);
        NSLog(@"Recording saved at path: %@",_videoPath);
    }];
}

#pragma mark - Screen Width & Height

- (NSInteger)screenHeight {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake((screenBounds.size.width * screenScale), (screenBounds.size.height * screenScale));
    NSInteger screenHeight = screenSize.height;
    return screenHeight;
}

- (NSInteger)screenWidth {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGSize screenSize = CGSizeMake((screenBounds.size.width * screenScale), (screenBounds.size.height * screenScale));
    NSInteger screenWidth = screenSize.width;
    return screenWidth;
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
