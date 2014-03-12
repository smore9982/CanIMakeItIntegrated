//
//  DataHelper.m
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "DataHelper.h"

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
    NSManagedObject *userData = [NSEntityDescription insertNewObjectForEntityForName:@"UserData" inManagedObjectContext:managedObjectContext];

    [userData setValue:key forKey:@"key"];
    [userData setValue:value forKey:@"value"];
    
    NSError *error = nil;
    //Save the object to persistent store
    
    if( ![managedObjectContext save:&error] )
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        return false;
    }
    return true;
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

- (NSArray*) getDepartureTimes{    
    return nil;
}



@end
