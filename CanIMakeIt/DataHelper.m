//
//  DataHelper.m
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "DataHelper.h"
#import "Utility.h"
#import "AdvisoryModel.h"

@implementation DataHelper
- (id) init {
    if ( self = [super init] )
    {
    
    }
    return self;
}

-(NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    
    if([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

- (NSString*) getUserData : (NSString*) key{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"key = %@",key];
    
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(error != nil){
        NSLog(@"Can't Retrieve data! %@ %@", error, [error localizedDescription]);
        return nil;
    }
    
    
    NSManagedObject* value = nil;
    for(int i=0; i<array.count;i++){
        value = [array objectAtIndex:i];
        return [value valueForKey:@"value"];
    }
    return nil;
}

- (BOOL) saveUserData : (NSString*) key withValue: (NSString*) value{
    //Create new device
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserData"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"key = %@",key];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(array.count > 0){
        NSLog(@"Found Value. Update");
        NSManagedObject* managedObject = [array objectAtIndex:0];
        [managedObject setValue:key forKey:@"key"];
        [managedObject setValue:value forKey:@"value"];
        return true;
    }else{
        NSLog(@"Did not find value. Insert");
        NSManagedObject *userData = [NSEntityDescription insertNewObjectForEntityForName:@"UserData" inManagedObjectContext:managedObjectContext];
        [userData setValue:key forKey:@"key"];
        [userData setValue:value forKey:@"value"];
        NSError *error = nil;
        if( ![managedObjectContext save:&error] )
        {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            return false;
        }
        return true;
    }
}


- (BOOL) isFirstLaunch{
    NSString* firstLaunch = [self getUserData:@"isFirstLaunch"];
    if(firstLaunch == nil || ![firstLaunch isEqual:@"true"]){
        return true;
    }else{
        return false;
    }
}

- (BOOL) setFirstLaunch : (BOOL) isFirstLaunch{
    return [self saveUserData:@"isFirstLaunch" withValue:@"true"];
}

- (void) loadStops:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock {
    NSString* hostName = @"http://ec2-54-85-36-246.compute-1.amazonaws.com:8080/CanIMakeWebService/";
    NSString* urlStr = [NSString stringWithFormat:@"%@/GetStops",hostName];
    NSURL *url= [NSURL URLWithString:urlStr];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    //Send an asyncronous request to get data from url.
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(@"");
            });
        }else{
            //Do json desrialization on data
            NSError* error;
            NSArray* stopsArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            //Iterate over array and parse json data
            for(int i=0;i<[stopsArray count];i++){
                //Each array object can be put into NSDictionary.
                NSDictionary* stopData = [stopsArray objectAtIndex:i];
                NSString* stopId = [stopData valueForKey:@"id"];
                NSString* stopName = [stopData valueForKey:@"name"];
                NSString* stopLat = [stopData valueForKey:@"lat"];
                NSString* stopLon = [stopData valueForKey:@"lon"];
                BOOL isTransferStation = [[stopData valueForKey:@"isTransferStation"]boolValue];
                NSString* stopAgency = [stopData valueForKey:@"agency"];
                [self saveStopWithID:stopId StopName:stopName StopLat:stopLat StopLon:stopLon StopAgency:stopAgency TransferPoint:isTransferStation];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(@"");
        });
    }];
}

-(void) saveStopWithID:(NSString*) stopId StopName:(NSString*) stopName StopLat:(NSString*)stopLat StopLon:(NSString*)stopLon StopAgency:(NSString*) stopAgency TransferPoint:(BOOL) isTransferPoint {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stops"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"stopId = %@ AND stopAgency = %@",stopId,stopAgency];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(array.count > 0){
        NSLog(@"Found Value. Update");
        NSManagedObject* managedObject = [array objectAtIndex:0];
        [managedObject setValue:stopName forKey:@"stopName"];
        [managedObject setValue:stopLat forKey:@"stopLat"];
        [managedObject setValue:stopLat forKey:@"stopLon"];
        [managedObject setValue:[NSNumber numberWithBool:isTransferPoint] forKey:@"isTransferStation"];
        return;
    }else{
        NSLog(@"Did not find value. Insert");
        NSManagedObject *stopData = [NSEntityDescription insertNewObjectForEntityForName:@"Stops" inManagedObjectContext:managedObjectContext];
        [stopData setValue:stopId forKey:@"stopId"];
        [stopData setValue:stopAgency forKey:@"stopAgency"];
        [stopData setValue:stopName forKey:@"stopName"];
        [stopData setValue:stopLat forKey:@"stopLat"];
        [stopData setValue:stopLon forKey:@"stopLon"];
        [stopData setValue:[NSNumber numberWithBool:isTransferPoint] forKey:@"isTransferStation"];
        NSError *error = nil;
        if( ![managedObjectContext save:&error] )
        {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            return;
        }
        return;
    }
}

-(NSArray*) getTransferStopsForAgency:(NSString *)agencyName{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stops"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"stopAgency = %@",agencyName];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray* stopArray = [[NSMutableArray alloc]init];
    for(int i=0; i< [array count]; i++){
        NSManagedObject* stopData = [array objectAtIndex:i];
        NSString* stopName = [stopData valueForKey:@"stopName"];
        BOOL isTransferPoint = [[stopData valueForKey:@"isTransferStation"]boolValue];
        if(isTransferPoint){
            [stopArray addObject:stopName];
        }
    }
    return stopArray;
}

-(NSArray*) getStopsForAgency:(NSString*) agencyName{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Stops"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"stopAgency = %@",agencyName];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    NSMutableArray* stopArray = [[NSMutableArray alloc]init];
    for(int i=0; i< [array count]; i++){
        NSManagedObject* stopData = [array objectAtIndex:i];
        NSString* stopName = [stopData valueForKey:@"stopName"];
        //StopModel* stopModel = [[StopModel alloc]init];
        //stopModel.stopId = [stopData valueForKey:@"stopId"];
        //stopModel.stopLat = [stopData valueForKey:@"stopLat"];
        //stopModel.stopLon = [stopData valueForKey:@"stopLon"];
        //stopModel.stopName = [stopData valueForKey:@"stopName"];
        //stopModel.stopAgency = [stopData valueForKey:@"stopAgency"];
        [stopArray addObject:stopName];
    }
    
    return stopArray;
}

- (void) saveTripDepartureTimesWithDepartureId : (NSString*) departureID DestionstionID :(NSString*) destinationId TransferID :(NSString*) transferId completion:(BOOL (^)(NSString*))completionBlock error:(BOOL (^)(NSString*))errorBlock{
    
    //Url of web service.
    NSString* hostName = @"http://ec2-54-85-36-246.compute-1.amazonaws.com:8080/CanIMakeWebService/";
    NSString* urlStr = [NSString stringWithFormat:@"%@/GetDepartureTimes?fromStationID=%@&toStationID=%@",hostName,departureID,destinationId];
    
    if(transferId != nil){
        urlStr = [NSString stringWithFormat:@"%@/GetDepartureTimes?fromStationID=%@&toStationID=%@&transferStationID=%@",hostName,departureID,destinationId,transferId];
    }
    
    NSURL *url= [NSURL URLWithString:urlStr];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(@"");
            });
        }else{
            NSLog(@"Sync Called");
            NSError* error;
            NSArray* departuresArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            if([departuresArray count] <= 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    errorBlock(@"No trips between the selected stops could be found");
                    return;
                });
            }else{
            
            //Iterate over array and parse json data
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            [[managedObjectContext persistentStoreCoordinator] lock];
                for(int i=0;i<[departuresArray count];i++){
                //Each array object can be put into NSDictionary.
                NSDictionary* departureData = [departuresArray objectAtIndex:i];
                NSString* departureId = [departureData valueForKey:@"departureStopId"];
                NSString* destinationId = [departureData valueForKey:@"destinationStopId"];
                NSString* departureDateStr = [departureData valueForKey:@"departureDate"];
                NSDate* date = [Utility stringToDateConversion:departureDateStr withFormat:@"yyyy-MM-dd"];
                NSArray* departureTimes = [departureData valueForKey:@"departureTimes"];
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DepartureTimes"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat: @"departureStopId = %@ AND destinationStopId = %@ AND departureDate =%@",departureId,destinationId,date];
                [fetchRequest setPredicate:predicate];
                NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                if(array.count > 0){
                    NSLog(@"Found Value. Update");
                    NSManagedObject* value = [array objectAtIndex:0];
                    [value setValue:departureId forKey:@"departureStopId"];
                    [value setValue:destinationId forKey:@"destinationStopId"];
                    [value setValue:date forKey:@"departureDate"];
                    [value setValue:departureTimes forKey:@"departureTimes"];

                }else{
                    NSLog(@"Did not find value. Insert");
                    NSManagedObject *newDeparture = [NSEntityDescription insertNewObjectForEntityForName:@"DepartureTimes" inManagedObjectContext:managedObjectContext];
                    [newDeparture setValue:departureId forKey:@"departureStopId"];
                    [newDeparture setValue:destinationId forKey:@"destinationStopId"];
                    [newDeparture setValue:date forKey:@"departureDate"];
                    [newDeparture setValue:departureTimes forKey:@"departureTimes"];
                }
            }
            [managedObjectContext save:&error];
            [[managedObjectContext persistentStoreCoordinator] unlock];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Going to call callback");
                completionBlock(@"");
            });
            }
        }
    }];
}

-(StopModel* ) getStopModelWithID: (NSString*) stopId{
    StopModel* stopModel = [[StopModel alloc]init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] initWithEntityName:@"Stops"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat: @"stopId = %@",stopId];
    [fetchRequest1 setPredicate:predicate1];
    
    NSError* error= nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest1 error:&error];
    
    if(array==nil || [array count] <=0){
        return nil;
    }
    
    NSManagedObject* stopData = [array objectAtIndex:0];
    stopModel.stopId = [stopData valueForKey:@"stopId"];
    stopModel.stopLat = [stopData valueForKey:@"stopLat"];
    stopModel.stopLon = [stopData valueForKey:@"stopLon"];
    stopModel.stopName = [stopData valueForKey:@"stopName"];
    stopModel.stopAgency = [stopData valueForKey:@"stopAgency"];
    return stopModel;
}

-(StopModel* ) getStopModelWithName: (NSString*) stopName{
    StopModel* stopModel = [[StopModel alloc]init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] initWithEntityName:@"Stops"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat: @"stopName = %@",stopName];
    [fetchRequest1 setPredicate:predicate1];
    
    NSError* error= nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest1 error:&error];
    
    if(array==nil || [array count] <=0){
        return nil;
    }
    
    NSManagedObject* stopData = [array objectAtIndex:0];
    stopModel.stopId = [stopData valueForKey:@"stopId"];
    stopModel.stopLat = [stopData valueForKey:@"stopLat"];
    stopModel.stopLon = [stopData valueForKey:@"stopLon"];
    stopModel.stopName = [stopData valueForKey:@"stopName"];
    stopModel.stopAgency = [stopData valueForKey:@"stopAgency"];
    return stopModel;
}

- (NSArray *) getTripDepartureTimesForDepartureId:(NSString*) departureID DestinationID:(NSString *)destionationId onDate:(NSDate*) departureDate{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSError* error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DepartureTimes"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"departureStopId = %@ AND destinationStopId = %@ AND departureDate =%@",departureID,destionationId,departureDate];
    [fetchRequest setPredicate:predicate];
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSManagedObject* value = nil;
    for(int i=0; i<array.count;i++){
        value = [array objectAtIndex:i];
        return [value valueForKey:@"departureTimes"];
    }
    return [[NSArray alloc]init];
}


- (TripProfileModel*) getDefaultProfileData{
    DataHelper* dataHelper = [[DataHelper alloc]init];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    TripProfileModel* tripModel = [[TripProfileModel alloc]init];
    //Get default tripID.
    
    NSString* objectUrl = [dataHelper getUserData:@"defaultTripID"];
    if(objectUrl == nil){
        return nil;
    }
    
    //Get default trip.
    NSURL* objectqeqerq = [NSURL URLWithString:objectUrl];
    NSManagedObjectID* tripId = [[managedObjectContext persistentStoreCoordinator]managedObjectIDForURIRepresentation:objectqeqerq];
    NSManagedObject* tripData = [managedObjectContext objectWithID:tripId];
    if(tripData == nil){
        return nil;
    }
    
    //Get Stop Data
    NSString* departureName = [tripData valueForKey:@"fromStation"];
    NSString* destinationName = [tripData valueForKey:@"toStation"];
    StopModel* departureStop = [self getStopModelWithName:departureName];
    StopModel* destinationStop = [self getStopModelWithName:destinationName];
    
    if(departureStop == nil || destinationStop == nil){
        return nil;
    }
    
    tripModel.tripObjectId = objectUrl;
    tripModel.departureId = departureStop.stopId;
    tripModel.destinationId = destinationStop.stopId;
    tripModel.departureTime = [tripData valueForKey:@"startTime"];
    tripModel.approxTimeToStation =[tripData valueForKey:@"tripTime"];
    tripModel.stopLat = destinationStop.stopLat;
    tripModel.stopLon = destinationStop.stopLon;
    tripModel.dateAdded = [tripData valueForKey:@"dateAdded"];
    return tripModel;
}

- (void) loadAgencies:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock{
    NSString* hostName = @"http://ec2-54-85-36-246.compute-1.amazonaws.com:8080/CanIMakeWebService/";
    NSString* urlStr = [NSString stringWithFormat:@"%@/GetLines",hostName];
    NSURL *url= [NSURL URLWithString:urlStr];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    //Send an asyncronous request to get data from url.
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(@"");
            });
        }else{
            //Do json desrialization on data
            NSError* error;
            NSArray* stopsArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            //Iterate over array and parse json data
            for(int i=0;i<[stopsArray count];i++){
                //Each array object can be put into NSDictionary.
                NSDictionary* stopData = [stopsArray objectAtIndex:i];
                NSString* agencyId = [stopData valueForKey:@"id"];
                NSString* agencyName = [stopData valueForKey:@"name"];
                [self saveAgencyWithID:agencyId AgencyName:agencyName];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(@"");
        });
    }];
}

-(void) saveAgencyWithID:(NSString*) agencyId AgencyName:(NSString*) agencyName  {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Agency"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"agencyId = %@",agencyId];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if(array.count > 0){
        NSLog(@"Found Value. Update");
        NSManagedObject* managedObject = [array objectAtIndex:0];
        [managedObject setValue:agencyId forKey:@"agencyId"];
        [managedObject setValue:agencyName forKey:@"agencyName"];
        return;
    }else{
        NSLog(@"Did not find value. Insert");
        NSManagedObject *agencyData = [NSEntityDescription insertNewObjectForEntityForName:@"Agency" inManagedObjectContext:managedObjectContext];
        [agencyData setValue:agencyId forKey:@"agencyId"];
        [agencyData setValue:agencyName forKey:@"agencyName"];
        NSError *error = nil;
        if( ![managedObjectContext save:&error] )
        {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            return;
        }
        return;
    }
}

-(NSArray*) getAgencyNames{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Agency"];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray* agencyArray = [[NSMutableArray alloc]init];
    for(int i=0; i< [array count]; i++){
        NSManagedObject* agencyData = [array objectAtIndex:i];
        NSString* agencyName = [agencyData valueForKey:@"agencyName"];\
        [agencyArray addObject:agencyName];
    }
    
    return agencyArray;
}

- (NSDictionary*) getAgencyData{
    
    
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Agency"];
    NSError *error = nil;
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *agencyIdArray = [[NSMutableArray alloc] init];
    NSMutableArray *agencyNameArray = [[NSMutableArray alloc] init];
    
    for(int i=0; i< [array count]; i++){
        NSManagedObject* agencyData = [array objectAtIndex:i];
        [agencyIdArray addObject:[agencyData valueForKey:@"agencyId"]];
        [agencyNameArray addObject:[agencyData valueForKey:@"agencyName"]];
    }
    
    NSDictionary* agencyModel =[NSDictionary dictionaryWithObjects:agencyNameArray forKeys:agencyIdArray];
    
    return agencyModel;
}


- (NSArray *) getTripRealTimes:(NSString*) tripId{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSError* error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"TripRealTime"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"tripID = %@",tripId];
    [fetchRequest setPredicate:predicate];
    NSArray* array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray* tripArray = [[NSMutableArray alloc]init];
    for(int i=0; i< [array count]; i++){
        NSManagedObject* tripData = [array objectAtIndex:i];
        NSString* tripTime = [tripData valueForKey:@"tripTime"];
        NSString* tripDate = [tripData valueForKey:@"tripDate"];
        
        [tripArray addObject:tripTime];
        [tripArray addObject:tripDate];
    }
    
    return tripArray;
}

-(void) saveTripRealTime: (NSInteger) realTimeinSec withTripId: (NSString *)tripId{
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSManagedObject *tripTime = [NSEntityDescription insertNewObjectForEntityForName:@"TripRealTimes" inManagedObjectContext:managedObjectContext];
    
    //Always insert trip time information with current timestamp
    [tripTime setValue:tripId forKeyPath:@"tripID"];
    [tripTime setValue:[NSNumber numberWithInteger:realTimeinSec] forKeyPath:@"tripTime"];
    [tripTime setValue:[NSDate date] forKeyPath:@"tripDate"];
    NSError *error = nil;
    
    if( ![managedObjectContext save:&error] )
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        return;
    }
    
    return;
}

- (int) getAdvisoryCount{
    return 10;
}

- (NSMutableDictionary *) getAdvisories{
    NSMutableDictionary* advisoryDict = [[NSMutableDictionary alloc]init];
    
    AdvisoryModel* model = [[AdvisoryModel alloc]init];
    model.advisoryLine = @"LIRR";
    model.advisoryText = @"THIS IS SOME TEST TEXT FOR ADVISORIES 1. huuawdhoiaw aidaj pdwopd  hiqpd pq qiopwp oqwq qwi jpqwejq  qoepoqwei qp qow   qoe p   oqei poqwie qwe qep qo";
    
    AdvisoryModel* model1 = [[AdvisoryModel alloc]init];
    model1.advisoryLine = @"LIRR";
    model1.advisoryText = @"THIS IS SOME TEST TEXT FOR ADVISORIES 2";
    
    NSMutableArray* lirrTrips = [[NSMutableArray alloc]init];
    [lirrTrips addObject:model];
    [lirrTrips addObject:model1];
    
    
    AdvisoryModel* model2 = [[AdvisoryModel alloc]init];
    model2.advisoryLine = @"NJT";
    model2.advisoryText = @"THIS IS SOME TEST TEXT FOR ADVISORIES 3";
    
    AdvisoryModel* model3 = [[AdvisoryModel alloc]init];
    model3.advisoryLine = @"NJT";
    model3.advisoryText = @"THIS IS SOME TEST TEXT FOR ADVISORIES 4";
    
    AdvisoryModel* model4 = [[AdvisoryModel alloc]init];
    model4.advisoryLine = @"NJT";
    model4.advisoryText = @"THIS IS SOME TEST TEXT FOR ADVISORIES 5";
    
    NSMutableArray* njtTrips = [[NSMutableArray alloc]init];
    [njtTrips addObject:model2];
    [njtTrips addObject:model3];
    [njtTrips addObject:model4];
    
    [advisoryDict setValue:lirrTrips forKey:@"LIRR"];
    
    [advisoryDict setValue:njtTrips forKey:@"NJT"];
    return advisoryDict;
}

@end
