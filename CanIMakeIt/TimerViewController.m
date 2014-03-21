//
//  ViewController.m
//  Timer
//
//  Created by Chris on 2014/2/27.
//  Copyright (c) 2014年 Chris. All rights reserved.
//

#import "TimerViewController.h"
#import "AppDelegate.h"
#import "DataHelper.h"
#import "Utility.h"
#import <CoreLocation/CoreLocation.h>

@interface TimerViewController ()

@property NSNumber *myNumber;
@property BOOL countdowning;
@property UILocalNotification *notification;
@property AppDelegate *appDelegate;
@property DataHelper* dataHelper;
@property int tripid;
@property NSDate* today;

@end

@implementation TimerViewController

- (void)viewDidLoad
{
    self.dataHelper = [[DataHelper alloc] init];
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    _today = [NSDate date];
    
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *CurrentTime = [outputFormatter stringFromDate:_today];
    NSDate *starttime = [outputFormatter dateFromString:tripProfileModel.departureTime];
    NSString *StartTime = [outputFormatter stringFromDate:starttime];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *CurrentDate = [outputFormatter stringFromDate:_today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
    //NSString *string = [tripTimes objectAtIndex: 1];
    NSString *nextTrain = [[NSString alloc]init];
    for (_tripid  = 0; _tripid < [tripTimes count]; _tripid++) {
        if ([CurrentTime compare:[tripTimes objectAtIndex:_tripid]] == NSOrderedAscending){
            nextTrain = [tripTimes objectAtIndex:_tripid];
            break;
        }
    }
    
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate * today1 = [NSDate date];
    NSDate *nexttrain = [outputFormatter dateFromString:nextTrain];
    NSString *departhour = [outputFormatter stringFromDate:starttime];
    NSString *nexttrainhour = [outputFormatter stringFromDate:nexttrain];
    NSString *currenthour = [outputFormatter stringFromDate:today1];
    [outputFormatter setDateFormat:@"mm:ss"];
    NSString *departmin = [outputFormatter stringFromDate:starttime];
    NSString *nexttrainmin = [outputFormatter stringFromDate:nexttrain];
    NSString *currentmin = [outputFormatter stringFromDate:today1];
    [outputFormatter setDateFormat:@"ss"];
    NSString *departsec = [outputFormatter stringFromDate:starttime];
    NSString *nexttrainsec = [outputFormatter stringFromDate:nexttrain];
    NSString *currentsec = [outputFormatter stringFromDate:today1];
    
    self.NextTrainTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[nexttrainhour integerValue], [nexttrainmin integerValue],[nexttrainsec integerValue]];
    
    /*if (StartTime > CurrentTime) {
     _counter = ([nexttrainhour integerValue] * 3600 + [nexttrainmin integerValue] * 60 + [nexttrainsec integerValue]) - ([departhour integerValue] * 3600 + [departmin integerValue] * 60 + [departsec integerValue]);
     }
     else{*/
    _counter = ([nexttrainhour integerValue] * 3600 + [nexttrainmin integerValue] * 60 + [nexttrainsec integerValue]) - ([currenthour integerValue] * 3600 + [currentmin integerValue] * 60 + [currentsec integerValue]);
    
    _appDelegate.counter = _counter;
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateTimer)
                                                         userInfo:nil
                                                          repeats:YES];
    
    _appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    _notification = [[UILocalNotification alloc] init];
    _app = [UIApplication sharedApplication];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                     degrees, minutes, seconds];
    _latlabel.text = lat;
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                       degrees, minutes, seconds];
    _longlabel.text = longt;
}

- (IBAction)Stop:(id)sender {
    [self.stopWatchTimer invalidate];
    self.stopWatchTimer = nil;
}

- (void)updateTimer
{
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    if(tripProfileModel == nil){
        [self performSegueWithIdentifier:@"SplashToTripsSegue" sender:self];
        return;
    }
    _counter = _counter - 1;
    _appDelegate.counter = _appDelegate.counter - 1;
    int hours = _counter / 3600;
    int minutes = (_counter - (hours * 3600)) / 60;
    int seconds = _counter - (hours * 3600) - (minutes * 60);
    int walktime = [tripProfileModel.approxTimeToStation intValue] * 60;
    self.WatchLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes,seconds];
    if (_counter == 0) {
        self.dataHelper = [[DataHelper alloc] init];
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
        [outputFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *CurrentDate = [outputFormatter stringFromDate:_today];
        NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
        NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
        
        NSString *current;
        NSString *next;
        
        if (_tripid + 1 == [tripTimes count]) {
            current = [tripTimes objectAtIndex: _tripid];
            _today = [_today dateByAddingTimeInterval:60*60*24];
            CurrentDate = [outputFormatter stringFromDate:_today];
            date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
            tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
            _tripid = 0;
            next = [tripTimes objectAtIndex:_tripid];
        }
        else {
            current = [tripTimes objectAtIndex: _tripid];
            next = [tripTimes objectAtIndex: _tripid + 1];
        }
        
        [outputFormatter setDateFormat:@"HH:mm:ss"];
        NSDate *currenttripTime = [outputFormatter dateFromString:current];
        NSDate *nexttripTime = [outputFormatter dateFromString:next];
        NSString *currenttripTimehour = [outputFormatter stringFromDate:currenttripTime];
        NSString *nexttripTimehour = [outputFormatter stringFromDate:nexttripTime];
        [outputFormatter setDateFormat:@"mm:ss"];
        NSString *currenttripTimemin = [outputFormatter stringFromDate:currenttripTime];
        NSString *nexttripTimemin = [outputFormatter stringFromDate:nexttripTime];
        [outputFormatter setDateFormat:@"ss"];
        NSString *currenttripTimesec = [outputFormatter stringFromDate:currenttripTime];
        NSString *nexttripTimesec = [outputFormatter stringFromDate:nexttripTime];
        
        int NEXTTRIPTIMEHOUR = [nexttripTimehour integerValue];
        if ([nexttripTimehour integerValue] < [currenttripTimehour integerValue]) {
            
            NEXTTRIPTIMEHOUR = NEXTTRIPTIMEHOUR + 24;
        }
        
        NSInteger add = (NEXTTRIPTIMEHOUR * 3600 + [nexttripTimemin integerValue] * 60 + [nexttripTimesec integerValue]) - ([currenttripTimehour integerValue] * 3600 + [currenttripTimemin integerValue] * 60 + [currenttripTimesec integerValue]);
        _counter = _counter + add;
        _tripid ++;
        self.NextTrainTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[nexttripTimehour integerValue], [nexttripTimemin integerValue],[nexttripTimesec integerValue]];
    }
    else if (_counter > walktime * 1.5){
        self.view.backgroundColor = [UIColor whiteColor];
    }
    else if (_counter == walktime * 1.5){
        if (_notification)
        {
            _notification.repeatInterval = 0;
            _notification.alertBody = @"You should leave now!!";
            [_app presentLocalNotificationNow:_notification];
        }
    }
    else if (_counter <= walktime * 1.5 && _counter > walktime){
        self.view.backgroundColor = [UIColor yellowColor];
    }
    else if (_counter == walktime){
        if (_notification)
        {
            _notification.repeatInterval = 0;
            _notification.alertBody = @"You should hurry up!!";
            [_app presentLocalNotificationNow:_notification];
        }
        
    }
    else if (_counter <= walktime){
        self.view.backgroundColor = [UIColor redColor];
    }
}

- (IBAction)SkipTrain:(id)sender {
    self.dataHelper = [[DataHelper alloc] init];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *CurrentDate = [outputFormatter stringFromDate:_today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
    
    NSString *current;
    NSString *next;

    if (_tripid + 1 == [tripTimes count]) {
        current = [tripTimes objectAtIndex: _tripid];
        _today = [_today dateByAddingTimeInterval:60*60*24];
        CurrentDate = [outputFormatter stringFromDate:_today];
        date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
        tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
        _tripid = 0;
        next = [tripTimes objectAtIndex:_tripid];
    }
    else {
        current = [tripTimes objectAtIndex: _tripid];
        next = [tripTimes objectAtIndex: _tripid + 1];
    }
    
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *currenttripTime = [outputFormatter dateFromString:current];
    NSDate *nexttripTime = [outputFormatter dateFromString:next];
    NSString *currenttripTimehour = [outputFormatter stringFromDate:currenttripTime];
    NSString *nexttripTimehour = [outputFormatter stringFromDate:nexttripTime];
    [outputFormatter setDateFormat:@"mm:ss"];
    NSString *currenttripTimemin = [outputFormatter stringFromDate:currenttripTime];
    NSString *nexttripTimemin = [outputFormatter stringFromDate:nexttripTime];
    [outputFormatter setDateFormat:@"ss"];
    NSString *currenttripTimesec = [outputFormatter stringFromDate:currenttripTime];
    NSString *nexttripTimesec = [outputFormatter stringFromDate:nexttripTime];
    
    int NEXTTRIPTIMEHOUR = [nexttripTimehour integerValue];
    if ([nexttripTimehour integerValue] < [currenttripTimehour integerValue]) {
        
        NEXTTRIPTIMEHOUR = NEXTTRIPTIMEHOUR + 24;
    }
    
    NSInteger add = (NEXTTRIPTIMEHOUR * 3600 + [nexttripTimemin integerValue] * 60 + [nexttripTimesec integerValue]) - ([currenttripTimehour integerValue] * 3600 + [currenttripTimemin integerValue] * 60 + [currenttripTimesec integerValue]);
    _counter = _counter + add;
    _tripid ++;
    self.NextTrainTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[nexttripTimehour integerValue], [nexttripTimemin integerValue],[nexttripTimesec integerValue]];
}

- (IBAction)GPS:(id)sender {
    [_locationManager startUpdatingLocation];
}
- (IBAction)ResetTimer:(id)sender {
    
    self.dataHelper = [[DataHelper alloc] init];
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    _today = [NSDate date];
    
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *CurrentTime = [outputFormatter stringFromDate:_today];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *CurrentDate = [outputFormatter stringFromDate:_today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
    NSString *nextTrain = [[NSString alloc]init];
    for (_tripid  = 0; _tripid < [tripTimes count]; _tripid++) {
        if ([CurrentTime compare:[tripTimes objectAtIndex:_tripid]] == NSOrderedAscending){
            nextTrain = [tripTimes objectAtIndex:_tripid];
            break;
        }
    }
    
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate * today1 = [NSDate date];
    NSDate *nexttrain = [outputFormatter dateFromString:nextTrain];
    NSString *nexttrainhour = [outputFormatter stringFromDate:nexttrain];
    NSString *currenthour = [outputFormatter stringFromDate:today1];
    [outputFormatter setDateFormat:@"mm:ss"];
    NSString *nexttrainmin = [outputFormatter stringFromDate:nexttrain];
    NSString *currentmin = [outputFormatter stringFromDate:today1];
    [outputFormatter setDateFormat:@"ss"];
    NSString *nexttrainsec = [outputFormatter stringFromDate:nexttrain];
    NSString *currentsec = [outputFormatter stringFromDate:today1];
    
    self.NextTrainTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[nexttrainhour integerValue], [nexttrainmin integerValue],[nexttrainsec integerValue]];
    
    _counter = ([nexttrainhour integerValue] * 3600 + [nexttrainmin integerValue] * 60 + [nexttrainsec integerValue]) - ([currenthour integerValue] * 3600 + [currentmin integerValue] * 60 + [currentsec integerValue]);
    
    _appDelegate.counter = _counter;
    
}
@end