//
//  Utility.m
//  CanIMakeIt
//
//  Created by More, Sameer on 3/12/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "Utility.h"

@implementation Utility
+ (NSDate*) stringToDateConversion:(NSString*) dateStr withFormat:(NSString*) formatStr{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:formatStr];
    
    NSDate *myDate = [dateFormatter dateFromString:dateStr];
    return myDate;
    
}

+ (NSString *) convertTripTimeToMinutes:(NSString *)tripTimeStr
{
    if (tripTimeStr == nil) return nil;
    
    NSArray *hourMin = [tripTimeStr componentsSeparatedByString:@" "];
    
    int min = (int)[hourMin[2] intValue];
    int hour = (int) [hourMin[0] intValue];
    int total = min + (hour * 60);
    
    NSString *retMinutes = [NSString stringWithFormat:@"%d", total];
    
    return retMinutes;
}

+ (NSString *) convertMinutesToTripTimeStr:(NSString *)tripMins
{
    if(tripMins == nil) return nil;
    
    int total = (int)[tripMins intValue];
    
    int min = 0, hour = 0;
    
    hour = total / 60;
    min = total - (hour * 60);
    
    NSString *retTripTime = [NSString stringWithFormat:@"%d hour %02d minutes", hour, min];
    
    return retTripTime;

}

+ (NSString *) convertTimeto24Hour:(NSString *)timeIn12
{
    if(timeIn12 == nil) return nil;
    
    NSArray *hourMin = [timeIn12 componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
    
    int phour = (int)[hourMin[0] intValue];
    int pminute = (int)[hourMin[1] intValue];
    
    NSString *timeIn24;
    if([[hourMin objectAtIndex:2] isEqualToString:@"AM"])
    {
        if (phour == 12)
        {
            timeIn24 = [NSString stringWithFormat:@"00:%02d:00", pminute];
        }
        else
        {
            timeIn24 = [NSString stringWithFormat:@"%02d:%02d:00", phour, pminute];
        }
    }
    else
    {
        if (phour == 12)
        {
            timeIn24 = [NSString stringWithFormat:@"%02d:%02d:00", phour, pminute];
        }
        else
        {
            timeIn24 = [NSString stringWithFormat:@"%02d:%02d:00", phour+12, pminute];
        }
    }
    
    return timeIn24;
}

+ (NSString *) convertTimeto12Hour:(NSString *)timeIn24
{
    if(timeIn24 == nil) return nil;
    
    NSArray *timeMerd = [timeIn24 componentsSeparatedByString:@":"];
    int mhour = (int)[timeMerd[0] intValue];
    int mmin = (int)[timeMerd[1] intValue];
    
    NSString *retTimeMerd;
    
    if(mhour > 12)
        retTimeMerd = [NSString stringWithFormat:@"%d:%02d PM", mhour-12, mmin];
    else if (mhour == 12)
        retTimeMerd = [NSString stringWithFormat:@"%d:%02d PM", mhour, mmin];
    else
        retTimeMerd = [NSString stringWithFormat:@"%d:%02d AM", mhour, mmin];
    
    return retTimeMerd;
}

+ (double) secondsToDays:(double) seconds{
    return (seconds)/86400;
}

@end
