//
//  DataHelper.m
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "DataHelper.h"
#import "Utility.h"

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
                NSString* stopAgency = @"LIRR";
                [self saveStopWithID:stopId StopName:stopName StopLat:stopLat StopLon:stopLon StopAgency:stopAgency];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(@"");
        });
    }];
}

-(void) saveStopWithID:(NSString*) stopId StopName:(NSString*) stopName StopLat:(NSString*)stopLat StopLon:(NSString*)stopLon StopAgency:(NSString*) stopAgency{
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
        return;
    }else{
        NSLog(@"Did not find value. Insert");
        NSManagedObject *stopData = [NSEntityDescription insertNewObjectForEntityForName:@"Stops" inManagedObjectContext:managedObjectContext];
        [stopData setValue:stopId forKey:@"stopId"];
        [stopData setValue:stopAgency forKey:@"stopAgency"];
        [stopData setValue:stopName forKey:@"stopName"];
        [stopData setValue:stopLat forKey:@"stopLat"];
        [stopData setValue:stopLon forKey:@"stopLon"];
        NSError *error = nil;
        if( ![managedObjectContext save:&error] )
        {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            return;
        }
        return;
    }
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

- (void) saveTripDepartureTimesWithDepartureId : (NSString*) departureID DestionstionID :(NSString*) destinationId completion:(void (^)(NSString*))completionBlock error:(void (^)(NSString*))errorBlock{
    
    //Url of web service.
    NSString* hostName = @"http://ec2-54-85-36-246.compute-1.amazonaws.com:8080/CanIMakeWebService/";
    NSString* urlStr = [NSString stringWithFormat:@"%@/GetDepartureTimes?fromStationID=%@&toStationID=%@",hostName,departureID,destinationId];
    NSURL *url= [NSURL URLWithString:urlStr];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(@"");
            });
        }else{
            NSError* error;
            NSArray* departuresArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            //Iterate over array and parse json data
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
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
                
                [managedObjectContext save:&error];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *responeStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                completionBlock(@"");
            });
        }
    }];
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
    
    tripModel.departureId = departureStop.stopId;
    tripModel.destinationId = destinationStop.stopId;
    tripModel.departureTime = [tripData valueForKey:@"startTime"];
    tripModel.approxTimeToStation =[tripData valueForKey:@"tripTime"];
    tripModel.stopLat = destinationStop.stopLat;
    tripModel.stopLon = destinationStop.stopLon;
    return tripModel;
}
@end
