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

enum {
    kIODefaultCache		 = 0,
    kIOInhibitCache		 = 1,
    kIOWriteThruCache    = 2,
    kIOCopybackCache     = 3,
    kIOWriteCombineCache = 4
};

enum {
    kIOMapAnywhere		    = 0x00000001,
    kIOMapCacheMask		    = 0x00000700,
    kIOMapCacheShift		= 8,
    kIOMapDefaultCache		= kIODefaultCache      << kIOMapCacheShift,
    kIOMapInhibitCache		= kIOInhibitCache      << kIOMapCacheShift,
    kIOMapWriteThruCache	= kIOWriteThruCache    << kIOMapCacheShift,
    kIOMapCopybackCache		= kIOCopybackCache     << kIOMapCacheShift,
    kIOMapWriteCombineCache	= kIOWriteCombineCache << kIOMapCacheShift,
    kIOMapUserOptionsMask	= 0x00000fff,
    kIOMapReadOnly		    = 0x00001000,
    kIOMapStatic		    = 0x01000000,
    kIOMapReference		    = 0x02000000,
    kIOMapUnique		    = 0x04000000
#ifdef XNU_KERNEL_PRIVATE
    , kIOMap64Bit		    = 0x08000000
#endif
};

__END_DECLS

@interface ScreenRecorder : NSObject

- (instancetype)initWithFramerate:(CGFloat)framerate bitrate:(CGFloat)bitrate;
- (void)openFramebuffer;
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