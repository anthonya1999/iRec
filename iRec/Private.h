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

__END_DECLS

IOMobileFramebufferConnection _framebufferConnection;
IOSurfaceRef _screenSurface;
CVPixelBufferRef _pixelBuffer;
AVAssetWriter *_videoWriter;
AVAssetWriterInput *_videoWriterInput;
AVAssetWriterInputPixelBufferAdaptor *_pixelBufferAdaptor;
dispatch_queue_t _videoQueue;
NSLock *_pixelBufferLock;
int _framerate, _bitrate;

@end