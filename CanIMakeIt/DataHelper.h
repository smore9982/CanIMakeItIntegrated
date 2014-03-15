//
//  DataHelper.h
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHelper : NSObject
- (NSString *) getUserData : (NSString*) key;
- (BOOL) saveUserData : (NSString*) key withValue: (NSString*) value;
- (BOOL) isFirstLaunch;
- (BOOL) setFirstLaunch : (BOOL) isFirstLaunch;
- (void) saveTripDepartureTimesWithDepartureId : (NSString*) departureID DestionstionID :(NSString*) destinationId completion:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock;
- (NSArray*) getTripDepartureTimesForDepartureId:(NSString*) departureID DestinationID:(NSString*) destionationId onDate:(NSDate*) departureDate;
- (void) loadStops:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock;
- (NSArray*) getStopsForAgency:(NSString*) agencyName;
@end
