//
//  Utility.h
//  CanIMakeIt
//
//  Created by More, Sameer on 3/12/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
+ (NSDate*) stringToDateConversion:(NSString*) dateStr withFormat:(NSString*) formatStr;
+ (NSString *) convertTripTimeToMinutes:(NSString *)tripTimeStr;
+ (NSString *) convertMinutesToTripTimeStr:(NSString *)tripMins;
+ (NSString *) convertTimeto24Hour:(NSString *)timeIn12;
+ (NSString *) convertTimeto12Hour:(NSString *)timeIn24;
+ (double) secondsToDays:(double) seconds;
@end
