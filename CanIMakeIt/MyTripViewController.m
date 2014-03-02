//
//  MyTripViewController.m
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "MyTripViewController.h"

@interface MyTripViewController ()

@end

@implementation MyTripViewController

@synthesize contactdb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(self.contactdb)
    {
        [self.fromStation setText:[self.contactdb valueForKey:@"fromStation"]];
        [self.toStation setText:[self.contactdb valueForKey:@"toStation"]];
        [self.startTime setText:[self.contactdb valueForKey:@"startTime"]];
        [self.tripTime setText:[self.contactdb valueForKey:@"tripTime"]];
        
    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SaveTripButton:(id)sender {

    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (self.contactdb)
    {
        //Update existing device
        [self.contactdb setValue:self.fromStation.text forKey:@"fromStation"];
        [self.contactdb setValue:self.toStation.text forKey:@"toStation"];
        [self.contactdb setValue:self.startTime.text forKey:@"startTime"];
        [self.contactdb setValue:self.tripTime.text forKey:@"tripTime"];
    }
    else
    {
        //Create new device
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Trips" inManagedObjectContext:context];
        [newDevice setValue:self.fromStation.text forKey:@"fromStation"];
        [newDevice setValue:self.toStation.text forKey:@"toStation"];
        [newDevice setValue:self.startTime.text forKey:@"startTime"];
        [newDevice setValue:self.tripTime.text forKey:@"tripTime"];
    }
    
    NSError *error = nil;
    //Save the object to persistent store
    if(![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)backButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
