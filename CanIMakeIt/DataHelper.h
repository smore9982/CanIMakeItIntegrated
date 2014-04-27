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
-(BOOL) deleteUserData : (NSString*) key;
    
- (BOOL) isFirstLaunch;
- (BOOL) setFirstLaunch : (BOOL) isFirstLaunch;

- (void) saveTripDepartureTimesWithDepartureId : (NSString*) departureID DestionstionID :(NSString*) destinationId TransferID :(NSString*) transferId completion:(BOOL (^)(NSString*))completionBlock error:(BOOL (^)(NSString*))errorBlock;
- (NSArray*) getTripDepartureTimesForDepartureId:(NSString*) departureID DestinationID:(NSString*) destionationId onDate:(NSDate*) departureDate;

- (void) loadStops:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock;
- (NSArray*) getStopsForAgency:(NSString*) agencyName;
- (NSArray*) getTransferStopsForAgency: (NSString*) agencyName;
- (StopModel* ) getStopModelWithName: (NSString*) stopName;
- (StopModel* ) getStopModelWithID: (NSString*) stopId;

- (void) loadAgencies:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock;
- (NSArray*) getAgencyNames;
- (NSDictionary*) getAgencyData;

- (TripProfileModel* )getDefaultProfileData;

- (NSString *) getTripRealTimes:(NSString*) tripId;
-(void) saveTripRealTime: (NSInteger) realTimeinSec withTripId: (NSString *)tripId;

- (void) getAdvisoryCount: (void (^)(int))completionBlock;
- (int) getAdvisoryCountFromLocalDB;
- (NSMutableDictionary *) getAdvisories;
- (NSString*) getDepartureStops;

@end
