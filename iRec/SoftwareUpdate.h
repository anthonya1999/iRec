//
//  SoftwareUpdate.h
//  ScreenRecord
//
//  Created by Anthony Agatiello on 7/13/14.
//  Copyright (c) 2014 Anthony Agatiello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoftwareUpdate : NSObject <NSCoding>

@property (readonly, copy, nonatomic) NSString *name;
@property (readonly, copy, nonatomic) NSString *version;
@property (readonly, copy, nonatomic) NSString *developer;
@property (readonly, copy, nonatomic) NSString *releaseNotes;
@property (readonly, copy, nonatomic) NSURL *url;
@property (readonly, copy, nonatomic) NSString *minimumiOSVersion;

@property (readonly, nonatomic) long long size;
@property (readonly, copy, nonatomic) NSString *localizedSize;

@property (readonly, nonatomic, getter=isNewerThanAppVersion) BOOL newerThanAppVersion;
@property (readonly, nonatomic, getter=isSupportedOnCurrentiOSVersion) BOOL supportedOnCurrentiOSVersion;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithData:(NSData *)data;

- (NSData *)dataRepresentation;

@end
