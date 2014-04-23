//
//  TripDetailViewController.m
//  CanIMakeIt
//
//  Created by DAKSHAYANI PADMAN on 3/15/14.
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
@property NSDate *dateAdded;
@property NSString *recordedTripTime;

@end

@implementation TripDetailViewController
@synthesize contactdb;
@synthesize agencyModel;
@synthesize dataHelp;
@synthesize agencyId;
@synthesize useTripTimeLabel;
@synthesize useRecTripTimeSwitch;
@synthesize recordedTripTime;


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
    
    //IF no trip time is recorded, hide the label and switch
    [self.useTripTimeLabel setHidden:YES];
    [self.useRecTripTimeSwitch setHidden:YES];
    
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
        
        //Show Average Recorded Time to Departure Station
        NSManagedObjectID *tripObject = [self.contactdb objectID];
        
        //Gets the object ID that uniquely identifies a row in table - Trips
        NSURL *objecturl = [tripObject URIRepresentation];
        
        NSString *objectUrlString = [objecturl absoluteString];
        
        
        self.recordedTripTime = [self.dataHelp getTripRealTimes:objectUrlString];
        if (self.recordedTripTime != nil)
        {
            int rec_hr = [self.recordedTripTime integerValue] / 3600;
            int rec_min = ([self.recordedTripTime integerValue] / 60) % 60;
            int rec_sec = [self.recordedTripTime integerValue] % 60 ;
    
            [self.recordedtripTimeLabel setText:[NSString stringWithFormat:@"*Average recorded time to the departure station is %02d:%02d:%02d", rec_hr, rec_min, rec_sec]];
        
            self.recordedtripTimeLabel.numberOfLines = 0;
            self.recordedtripTimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
            
            [self.useTripTimeLabel setHidden:NO];
            [self.useRecTripTimeSwitch setHidden:NO];

        }
        
        self.dateAdded = [self.contactdb valueForKey:@"dateAdded"];
        double interval = [self.dateAdded timeIntervalSinceNow];
        double intervalToDays = [Utility secondsToDays:(-1*interval)];
        if(intervalToDays < 1 ){
            self.updateButton.hidden = YES;
        }
        
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
    
    //Saving Default Trip object url to database context
    DataHelper *saveDataHelper = [[DataHelper alloc] init];
    [saveDataHelper saveUserData:@"defaultTripID" withValue:objectUrlString];
}

- (IBAction)updateTrip:(id)sender {
    NSString* departureStationName = [self.contactdb valueForKey:@"fromStation"];
    NSString* desinationStationName = [self.contactdb valueForKey:@"toStation"];
    NSString* transferStationName = [self.contactdb valueForKey:@"transferStation"];
    
    StopModel* departureStation=[self.dataHelp getStopModelWithName:departureStationName];
    StopModel* destinationStation=[self.dataHelp getStopModelWithName:desinationStationName];
    StopModel* transferStation=[self.dataHelp getStopModelWithName:transferStationName];
    
    [self.dataHelp saveTripDepartureTimesWithDepartureId:departureStation.stopId DestionstionID:destinationStation.stopId TransferID:transferStation.stopId completion:^(NSString *onComp){
            return YES;
        }
        error:^(NSString *onErr){
            return NO;
        }];
}

-(IBAction)YesNoSwitch:(id)sender
{
    if (useRecTripTimeSwitch.on)
    {
        if (self.contactdb)
        {
            [self.contactdb setValue:self.recordedTripTime forKeyPath:@"tripTime"];
            
            //Update Trip Time
            NSString *tripMin = [Utility convertMinutesToTripTimeStr:[self.contactdb valueForKey:@"tripTime"]];
            [self.tripTimeLabel setText:tripMin];
        }
    }
    
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
