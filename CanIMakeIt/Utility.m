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
@end
