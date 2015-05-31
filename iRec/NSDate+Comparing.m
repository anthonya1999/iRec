//
//  NSDate+Comparing.m
//  ScreenRecord
//
//  Created by Anthony Agatiello on 1/5/14.
//  Copyright (c) 2014 Anthony Agatiello. All rights reserved.
//

#import "NSDate+Comparing.h"
#import <UIKit/UIKit.h>

@implementation NSDate (Comparing)

- (NSInteger)daysSinceDate:(NSDate *)date
{
    // Return the inverse
    return [date daysUntilDate:self];
}

- (NSInteger)daysUntilDate:(NSDate *)date
{
    if (date == nil)
    {
        return 0;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSInteger startDay = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:self];
        NSInteger endDay = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:date];
        return endDay - startDay;
    }
    
    else {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger startDay = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:self];
        NSInteger endDay = [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:date];
        return endDay - startDay;

    }
}

@end
