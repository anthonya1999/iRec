//
//  Private.h
//  iRec
//
//  Created by Anthony Agatiello on 7/29/15.
//  Copyright © 2015 ADA Tech, LLC. All rights reserved.
//

@implementation NSObject (Private)

__BEGIN_DECLS

typedef struct __IOSurface *IOSurfaceRef;
typedef void *IOMobileFramebufferConnection;

#pragma mark - IOServiceAuthorize

enum {
    kIOServiceInteractionAllowed = 0x00000001
};

#pragma mark - IOSurfaceLock & IOSurfaceUnlock

typedef CF_OPTIONS(uint32_t, IOSurfaceLockOptions)
{
    kIOSurfaceLockReadOnly  = 0x00000001,
    kIOSurfaceLockAvoidSync = 0x00000002
};

#pragma mark - IOSurfaceCacheMode

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

IOMobileFramebufferConnection _framebufferConnection;
IOSurfaceRef _screenSurface;
size_t _bytesPerRow;
OSType _pixelFormat;
AVAssetWriter *_videoWriter;
CFDictionaryRef _properties;
AVAssetWriterInput *_videoWriterInput; //*_audioWriterInput;
AVAssetWriterInputPixelBufferAdaptor *_pixelBufferAdaptor;
dispatch_queue_t _videoQueue;
NSLock *_pixelBufferLock;
int _framerate, _bitrate;
void *_IOSurface;

@end
