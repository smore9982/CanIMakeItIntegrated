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

@end

@implementation TimerViewController

- (void)viewDidLoad
{
    self.dataHelper = [[DataHelper alloc] init];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * today = [NSDate date];
    NSString *CurrentDate = [outputFormatter stringFromDate:today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:@"8" DestinationID:@"55" onDate:date];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *CurrentTime = [outputFormatter stringFromDate:today];
    NSString *nextTrain = [[NSString alloc]init];
    for (_tripid  = 0; _tripid < [tripTimes count]; _tripid++) {
        if ([CurrentTime compare:[tripTimes objectAtIndex:_tripid]] == NSOrderedAscending){
            nextTrain = [tripTimes objectAtIndex:_tripid];
            break;
        }
    }
    NSDate *nexttrain = [outputFormatter dateFromString:nextTrain];
    NSString *nexttrainhour = [outputFormatter stringFromDate:nexttrain];
    [outputFormatter setDateFormat:@"mm:ss"];
    NSString *nexttrainmin = [outputFormatter stringFromDate:nexttrain];
    [outputFormatter setDateFormat:@"ss"];
    NSString *nexttrainsec = [outputFormatter stringFromDate:nexttrain];
    
    self.NextTrainTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[nexttrainhour integerValue], [nexttrainmin integerValue],[nexttrainsec integerValue]];
    
    _appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    _notification = [[UILocalNotification alloc] init];
    _app = [UIApplication sharedApplication];
    _countdowning = TRUE;
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

- (IBAction)Start:(id)sender {
    self.dataHelper = [[DataHelper alloc] init];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    NSDate * today = [NSDate date];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    //NSString *CurrentTime = [outputFormatter stringFromDate:today];
    NSDate *starttime = [outputFormatter dateFromString:@"12:00:00"];
    NSString *StartTime = [outputFormatter stringFromDate:starttime];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *CurrentDate = [outputFormatter stringFromDate:today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:@"8" DestinationID:@"55" onDate:date];
    //NSString *string = [tripTimes objectAtIndex: 1];
    NSString *nextTrain = [[NSString alloc]init];
    for (_tripid  = 0; _tripid < [tripTimes count]; _tripid++) {
        if ([StartTime compare:[tripTimes objectAtIndex:_tripid]] == NSOrderedAscending){
            nextTrain = [tripTimes objectAtIndex:_tripid];
            break;
        }
    }

    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSDate *nexttrain = [outputFormatter dateFromString:nextTrain];
    NSString *departhour = [outputFormatter stringFromDate:starttime];
    NSString *nexttrainhour = [outputFormatter stringFromDate:nexttrain];
    [outputFormatter setDateFormat:@"mm:ss"];
    NSString *departmin = [outputFormatter stringFromDate:starttime];
    NSString *nexttrainmin = [outputFormatter stringFromDate:nexttrain];
    [outputFormatter setDateFormat:@"ss"];
    NSString *departsec = [outputFormatter stringFromDate:starttime];
    NSString *nexttrainsec = [outputFormatter stringFromDate:nexttrain];
    NSLog(@"%@", nextTrain);
    
    self.NextTrainTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[nexttrainhour integerValue], [nexttrainmin integerValue],[nexttrainsec integerValue]];
    
    if (_countdowning == TRUE) {
        _counter = ([nexttrainhour integerValue] * 3600 + [nexttrainmin integerValue] * 60 + [nexttrainsec integerValue]) - ([departhour integerValue] * 3600 + [departmin integerValue] * 60 + [departsec integerValue]);
        _appDelegate.counter = _counter;
        self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(updateTimer)
                                                             userInfo:nil
                                                              repeats:YES];
        _countdowning = FALSE;
    }
    else{
        [self.stopWatchTimer invalidate];
        self.stopWatchTimer = nil;
        self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector(updateTimer)
                                                             userInfo:nil
                                                              repeats:YES];
    }
    
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
    int walktime = [tripProfileModel.approxTimeToStation intValue];
    self.WatchLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes,seconds];
    if (_counter == 0) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        _myNumber = [f numberFromString:self.SetTime.text];
        _counter = [_myNumber integerValue];
        _appDelegate.counter = _counter;
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
    else if (_counter <= 5){
        self.view.backgroundColor = [UIColor redColor];
    }
}

- (IBAction)SkipTrain:(id)sender {
    self.dataHelper = [[DataHelper alloc] init];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * today = [NSDate date];
    NSString *CurrentDate = [outputFormatter stringFromDate:today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:@"8" DestinationID:@"55" onDate:date];
    NSString *current = [tripTimes objectAtIndex: _tripid];
    NSString *next = [tripTimes objectAtIndex: _tripid + 1];
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
    NSInteger add = ([nexttripTimehour integerValue] * 3600 + [nexttripTimemin integerValue] * 60 + [nexttripTimesec integerValue]) - ([currenttripTimehour integerValue] * 3600 + [currenttripTimemin integerValue] * 60 + [currenttripTimesec integerValue]);
    NSLog(@"%ld",(long)add);
    _counter = _counter + add;
    _tripid ++;
    self.NextTrainTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",[nexttripTimehour integerValue], [nexttripTimemin integerValue],[nexttripTimesec integerValue]];
}

- (IBAction)GPS:(id)sender {
    
    [_locationManager startUpdatingLocation];
}
@end
