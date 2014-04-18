//
//  TripDetailViewController.m
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/15/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "TripDetailViewController.h"
#import "MyTripViewController.h"
#import "DataHelper.h"
#import "Utility.h"

@interface TripDetailViewController ()

@property NSDictionary *agencyModel;
@property NSString *agencyId;
@property DataHelper *dataHelp;

@end

@implementation TripDetailViewController
@synthesize contactdb;
@synthesize agencyModel;
@synthesize dataHelp;
@synthesize agencyId;


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
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
	// Do any additional setup after loading the view.
    
    //Get all agency information
    self.dataHelp = [[DataHelper alloc] init];
    self.agencyModel = [[NSDictionary alloc] init];
    self.agencyModel = [self.dataHelp getAgencyData];
    
    if(self.contactdb)
    {
        [self.fromStationLabel setText:[self.contactdb valueForKey:@"fromStation"]];
        [self.toStationLabel setText:[self.contactdb valueForKey:@"toStation"]];
        [self.transferStationLabel setText:[self.contactdb valueForKey:@"transferStation"]];
        
        NSString *tripMin = [Utility convertMinutesToTripTimeStr:[self.contactdb valueForKey:@"tripTime"]];
        [self.tripTimeLabel setText:tripMin];
        
        
        NSString *timeMerd = [Utility convertTimeto12Hour:[self.contactdb valueForKey:@"startTime"]];
        [self.startTimeLabel setText:timeMerd];
        
        //Set Agency label
        self.agencyId = [self.contactdb valueForKey:@"agencyId"];
        self.agencyLabel.text = [NSString stringWithFormat:@"* %@", self.agencyModel[self.agencyId]];
        
    }
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setDefaultTripButton:(id)sender
{
    NSManagedObjectID *tripObject = [self.contactdb objectID];
    
    //Gets the object ID that uniquely identifies a row in table - Trips
    NSURL *objecturl = [tripObject URIRepresentation];
    
    NSString *objectUrlString = [objecturl absoluteString];
    
    NSLog(@"the url -%@", objectUrlString);
    
    //Saving Default Trip object url to database context
    DataHelper *saveDataHelper = [[DataHelper alloc] init];
    [saveDataHelper saveUserData:@"defaultTripID" withValue:objectUrlString];
}



#pragma mark-
#pragma Navigation

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"updateTrips"])
    {
        MyTripViewController *destViewController = segue.destinationViewController;
        destViewController.contactdb = self.contactdb;
    }
}


@end
