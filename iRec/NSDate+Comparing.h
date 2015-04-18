//
//  NSDate+Comparing.h
//  ScreenRecord
//
//  Created by Anthony Agatiello on 1/5/14.
//  Copyright (c) 2014 Anthony Agatiello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Comparing)

- (NSInteger)daysSinceDate:(NSDate *)date;
- (NSInteger)daysUntilDate:(NSDate *)date;

@end
