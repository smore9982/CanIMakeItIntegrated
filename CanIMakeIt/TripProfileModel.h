//
//  TripProfileModel.h
//  CanIMakeIt
//
//  Created by More, Sameer on 3/15/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripProfileModel : NSObject
@property NSString* tripObjectId;
@property NSString* agencyId;
@property NSString* departureId;
@property NSString* destinationId;
@property NSString* departureTime;
@property NSString* approxTimeToStation;
@property NSString* stopLat;
@property NSString* stopLon;
@property NSDate* dateAdded;
@end
