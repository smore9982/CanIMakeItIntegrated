//
//  DataHelper.h
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TripProfileModel.h"
#import "StopModel.h"

@interface DataHelper : NSObject
-(NSManagedObjectContext *) managedObjectContext;
- (NSString *) getUserData : (NSString*) key;
- (BOOL) saveUserData : (NSString*) key withValue: (NSString*) value;
- (BOOL) isFirstLaunch;
- (BOOL) setFirstLaunch : (BOOL) isFirstLaunch;
- (void) saveTripDepartureTimesWithDepartureId : (NSString*) departureID DestionstionID :(NSString*) destinationId TransferID :(NSString*) transferId completion:(BOOL (^)(NSString*))completionBlock error:(BOOL (^)(NSString*))errorBlock;
- (void) saveTripDepartureTimesWithDepartureId : (NSString*) departureID DestionstionID :(NSString*) destinationId completion:(BOOL (^)(NSString*))completionBlock error:(BOOL (^)(NSString*))errorBlock;
- (NSArray*) getTripDepartureTimesForDepartureId:(NSString*) departureID DestinationID:(NSString*) destionationId onDate:(NSDate*) departureDate;
- (void) loadStops:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock;
- (NSArray*) getStopsForAgency:(NSString*) agencyName;
- (TripProfileModel* )getDefaultProfileData;
- (StopModel* ) getStopModelWithName: (NSString*) stopName;
- (StopModel* ) getStopModelWithID: (NSString*) stopId;
@end
