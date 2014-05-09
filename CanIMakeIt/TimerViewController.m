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
#import <QuartzCore/QuartzCore.h>
#import "ECSlidingViewController.h"
#import "ScheduleViewController.h"

@interface TimerViewController ()

@property NSNumber *myNumber;
@property UILocalNotification *notification;
@property AppDelegate *appDelegate;
@property DataHelper* dataHelper;
@property int tripid;
@property NSDate* today;
@property BOOL case1;
@property float counternow;
@property NSString* defaultStopLat;
@property NSString* defaultStopLongt;
@property NSString* currentLat;
@property NSString* currentLongt;
@property NSString* DTS;
@property double distance;
@property BOOL recording;
@property NSString* defulttripID;
@property int record1;
@property int record2;
@property NSString* DepartTime;
@property BOOL isRecording;

@end

@implementation TimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _case1 = true;
    _recording = true;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    self.WatchLabel.textColor = [UIColor lightGrayColor];
    
    self.dataHelper = [[DataHelper alloc] init];
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    StopModel* departureStation = [self.dataHelper getStopModelWithID:tripProfileModel.departureId];
    StopModel* destinationStation = [self.dataHelper getStopModelWithID:tripProfileModel.destinationId];
    
    
    self.TripDetailLabel.text = [NSString stringWithFormat:@"%@ to %@",departureStation.stopName,destinationStation.stopName];
    self.TripDetailLabel.textColor = [UIColor lightGrayColor];
    self.TripDetailLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:20];
    
    _defaultStopLat = departureStation.stopLat;
    _defaultStopLongt = departureStation.stopLon;
    _defulttripID = tripProfileModel.tripObjectId;

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *friendlyDateFormatter = [[NSDateFormatter alloc] init];

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
        else if ([CurrentTime compare:[tripTimes objectAtIndex:([tripTimes count] - 1)]] == NSOrderedDescending){
            _today = [_today dateByAddingTimeInterval:60*60*24];
            CurrentDate = [outputFormatter stringFromDate:_today];
            date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
            tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
            _tripid = 0;
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
    
    [friendlyDateFormatter setDateFormat:@"hh:mm a"];
    NSString* nextTrainTime = [friendlyDateFormatter stringFromDate:nexttrain];
    self.NextTrainTime.text = [NSString stringWithFormat:@"Next train leaves at %@", nextTrainTime];
    self.NextTrainTime.textColor = [UIColor lightGrayColor];
    self.NextTrainTime.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:16];

    int NEXTTRIPTIMEHOUR = [nexttrainhour integerValue];
    if ([nexttrainhour integerValue] < [currenthour integerValue]) {
        
        NEXTTRIPTIMEHOUR = NEXTTRIPTIMEHOUR + 24;
    }
    
    _counter = (NEXTTRIPTIMEHOUR * 3600 + [nexttrainmin integerValue] * 60 + [nexttrainsec integerValue]) - ([currenthour integerValue] * 3600 + [currentmin integerValue] * 60 + [currentsec integerValue]);
    
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
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    _ProgressToStation.progress = 0.0;
    [self performSelectorOnMainThread:@selector(ToStation) withObject:nil waitUntilDone:NO];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add a shadow to the top view so it looks like it is on top of the others
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    // Tell it which view should be created under left
    if (![self.slidingViewController.underRightViewController isKindOfClass:[ScheduleViewController class]]) {
        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleView"];
    }
    
    // Add the pan gesture to allow sliding
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)ToStation
{
    while (_case1) {
        _counternow = _counter;
        _case1 = false;
    }
    float actual = [_ProgressToStation progress];
    if (actual < 1.0) {
        _ProgressToStation.progress = 1.0 - (float)_counter / _counternow;
    }
    else if (actual == 1.0){
        _case1 = true;
    }
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ToStation) userInfo:nil repeats:NO];
}

-(void)RecordingTime
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time Stored"
                                                    message:@"You are close to departure station, and your travel time has been stored."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
        // .621371 mi = 1000 meters.
        if (_distance < 0.621371) {
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            [outputFormatter setDateFormat:@"HH:mm:ss"];
            NSDate * today1 = [NSDate date];
            NSString *currenthour = [outputFormatter stringFromDate:today1];
            [outputFormatter setDateFormat:@"mm:ss"];
            NSString *currentmin = [outputFormatter stringFromDate:today1];
            [outputFormatter setDateFormat:@"ss"];
            NSString *currentsec = [outputFormatter stringFromDate:today1];
            double RecordTo = [currenthour doubleValue] * 3600 + [currentmin doubleValue] * 60 + [currentsec doubleValue];
            _record2 = RecordTo;
            [_dataHelper saveTripRealTime:(_record2 - _record1) withTripId:_defulttripID];
            [alert show];
            _recording = true;
            [_RecordTimer invalidate];
            _RecordTimer = nil;
            _isRecording = false;
        }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Get the current location from here
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    NSString *lat = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    _currentLat = lat;
    NSString *longt = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
    _currentLongt = longt;
    _distance = sqrt(pow(fabs([_defaultStopLat doubleValue] - [_currentLat doubleValue]),2) + pow(fabs([_defaultStopLongt doubleValue] - [_currentLongt doubleValue]),2)) * 111000 * 0.000621371;

}

//Implement Countdown Timer
- (void)updateTimer
{
    [_locationManager startUpdatingLocation];
    
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    if(tripProfileModel == nil){
        [self performSegueWithIdentifier:@"TimerToTripsSegue" sender:self];
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
        
        NSDateFormatter *friendlyDateFormatter = [[NSDateFormatter alloc] init];
        [friendlyDateFormatter setDateFormat:@"hh:mm a"];
        NSString* nextTrainTime = [friendlyDateFormatter stringFromDate:nexttripTime];
        self.NextTrainTime.text = [NSString stringWithFormat:@"Next train leaves at %@", nextTrainTime];
        self.NextTrainTime.textColor = [UIColor lightGrayColor];
        self.NextTrainTime.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:16];
        
        _case1 = true;
        
    }
    else if (_counter > walktime * 1.5){
        self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        _A.titleLabel.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        _B.titleLabel.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        _C.titleLabel.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        _D.titleLabel.textColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    }
    else if (_counter == walktime * 1.5){
        if (_notification)
        {
            _notification.soundName =  UILocalNotificationDefaultSoundName;
            _notification.repeatInterval = 0;
            _notification.alertBody = @"You should get ready to leave.";
            [_app presentLocalNotificationNow:_notification];
        }
    }
    else if (_counter <= walktime * 1.5 && _counter > walktime){
        self.view.backgroundColor = [UIColor yellowColor];
        _A.titleLabel.textColor = [UIColor yellowColor];
        _B.titleLabel.textColor = [UIColor yellowColor];
        _C.titleLabel.textColor = [UIColor yellowColor];
        _D.titleLabel.textColor = [UIColor yellowColor];
    }
    else if (_counter == walktime){
        if (_notification)
        {
            _notification.soundName =  UILocalNotificationDefaultSoundName;
            _notification.repeatInterval = 0;
            _notification.alertBody = @"You should leave now.";
            [_app presentLocalNotificationNow:_notification];
        }
        
    }
    else if (_counter <= walktime){
        self.view.backgroundColor = [UIColor redColor];
        _A.titleLabel.textColor = [UIColor redColor];
        _B.titleLabel.textColor = [UIColor redColor];
        _C.titleLabel.textColor = [UIColor redColor];
        _D.titleLabel.textColor = [UIColor redColor];
    }
    
}

//Skip Train Button
- (IBAction)SkipTrain:(id)sender {

    _case1 = true;
    
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
    
    NSDateFormatter *friendlyDateFormatter = [[NSDateFormatter alloc] init];
    [friendlyDateFormatter setDateFormat:@"hh:mm a"];
    NSString* nextTrainTime = [friendlyDateFormatter stringFromDate:nexttripTime];
    self.NextTrainTime.text = [NSString stringWithFormat:@"Next train leaves at %@", nextTrainTime];
    self.NextTrainTime.textColor = [UIColor lightGrayColor];
    self.NextTrainTime.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:16];
}

//Reset Button
- (IBAction)ResetTimer:(id)sender {
    
    _case1 = true;
    
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
        else if ([CurrentTime compare:[tripTimes objectAtIndex:([tripTimes count] - 1)]] == NSOrderedDescending){
            _today = [_today dateByAddingTimeInterval:60*60*24];
            CurrentDate = [outputFormatter stringFromDate:_today];
            date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
            tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
            _tripid = 0;
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
    
    NSDateFormatter *friendlyDateFormatter = [[NSDateFormatter alloc] init];
    [friendlyDateFormatter setDateFormat:@"hh:mm a"];
    NSString* nextTrainTime = [friendlyDateFormatter stringFromDate:nexttrain];
    self.NextTrainTime.text = [NSString stringWithFormat:@"Next train leaves at %@", nextTrainTime];
    self.NextTrainTime.textColor = [UIColor lightGrayColor];
    self.NextTrainTime.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:16];
    
    int NEXTTRIPTIMEHOUR = [nexttrainhour integerValue];
    if ([nexttrainhour integerValue] < [currenthour integerValue]) {
        
        NEXTTRIPTIMEHOUR = NEXTTRIPTIMEHOUR + 24;
    }
    
    _counter = (NEXTTRIPTIMEHOUR * 3600 + [nexttrainmin integerValue] * 60 + [nexttrainsec integerValue]) - ([currenthour integerValue] * 3600 + [currentmin integerValue] * 60 + [currentsec integerValue]);
    
    _appDelegate.counter = _counter;
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    int walktime = [tripProfileModel.approxTimeToStation intValue];
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:25];
            if (_counter > walktime * 1.5){
                button.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];;
            }
            else if (_counter <= walktime * 1.5 && _counter > walktime){
                button.backgroundColor = [UIColor yellowColor];
            }
            else if (_counter <= walktime){
                button.backgroundColor = [UIColor redColor];
            }
            button.titleLabel.textColor = [UIColor lightGrayColor];
        }
    }
}

//Action Sheet Menu
-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Record",@"Stop Record", @"Recommended Time", nil];
    [actionSheet showInView:self.view];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

     switch (buttonIndex) {
         case 0:
         {
             NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
             [outputFormatter setDateFormat:@"HH:mm:ss"];
             NSDate * today1 = [NSDate date];
             NSString *currenthour = [outputFormatter stringFromDate:today1];
             [outputFormatter setDateFormat:@"mm:ss"];
             NSString *currentmin = [outputFormatter stringFromDate:today1];
             [outputFormatter setDateFormat:@"ss"];
             NSString *currentsec = [outputFormatter stringFromDate:today1];
             double RecordFrom = [currenthour doubleValue] * 3600 + [currentmin doubleValue] * 60 + [currentsec doubleValue];
             _record1 = RecordFrom;
             NSLog(@"%d",_record1);
             if (_recording) {
                 _RecordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                 target:self
                                                               selector:@selector(RecordingTime)
                                                               userInfo:nil
                                                                repeats:YES];
                 _recording = false;
             }
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"Start Recording"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
             _isRecording = true;
         }
             break;
         case 1:
         {
             if (!_isRecording) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Did not start timer"
                                                                 message:@"Click record first"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles:nil];
                 [alert show];
                 
             }else{
                 _isRecording = false;
                 NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                 [outputFormatter setDateFormat:@"HH:mm:ss"];
                 NSDate * today1 = [NSDate date];
                 NSString *currenthour = [outputFormatter stringFromDate:today1];
                 [outputFormatter setDateFormat:@"mm:ss"];
                 NSString *currentmin = [outputFormatter stringFromDate:today1];
                 [outputFormatter setDateFormat:@"ss"];
                 NSString *currentsec = [outputFormatter stringFromDate:today1];
                 double RecordTo = [currenthour doubleValue] * 3600 + [currentmin doubleValue] * 60 + [currentsec doubleValue];
                 _record2 = RecordTo;
                 [_dataHelper saveTripRealTime:(_record2 - _record1) withTripId:_defulttripID];
                 _recording = true;
                 [_RecordTimer invalidate];
                 _RecordTimer = nil;
                 
                 int seconds = (_record2 - _record1) % 60;
                 int minutes = ((_record2 - _record1) / 60) % 60;
                 int hours = (_record2 - _record1) / 3600;
                 
                 NSString* timeRecorded = [NSString stringWithFormat:@"%d hours,%d minutes, and %d seconds",hours,minutes,seconds];
                 NSString* msg = [NSString stringWithFormat:@"You reached the station in %@",timeRecorded];
                 
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Time Stored"
                                                    message:msg
                                                    delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];

                 [alert show];
             }
         }
             break;
         case 2:
         {
             self.dataHelper = [[DataHelper alloc] init];
             TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
             NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
             [outputFormatter setDateFormat:@"HH:mm:ss"];
             [outputFormatter setDateFormat:@"yyyy-MM-dd"];
             NSString *CurrentDate = [outputFormatter stringFromDate:_today];
             NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
             NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
             NSString* nextTrain = [tripTimes objectAtIndex:_tripid];
             [outputFormatter setDateFormat:@"HH:mm:ss"];
             NSDate *nexttrain = [outputFormatter dateFromString:nextTrain];
             NSString *nexttrainhour = [outputFormatter stringFromDate:nexttrain];
             [outputFormatter setDateFormat:@"mm:ss"];
             NSString *nexttrainmin = [outputFormatter stringFromDate:nexttrain];
             [outputFormatter setDateFormat:@"ss"];
             NSString *nexttrainsec = [outputFormatter stringFromDate:nexttrain];
             
             //.00086 mile per second = 3.1 miles per hour /(3600) Average walking speed.
             double time = _distance / 0.00086;
             double nexttraintime = [nexttrainhour doubleValue] * 3600 + [nexttrainmin doubleValue] * 60 + [nexttrainsec doubleValue];
             double suggesttime = nexttraintime - time;
             
             while (suggesttime < 0) {
                 suggesttime = suggesttime + 24 * 3600;
             }
             
             int suggesthour = suggesttime / 3600;
             int suggestmin = (suggesttime - (suggesthour * 3600)) / 60;
             NSString *AMPM;
             
             if (suggesthour == 0) {
                 AMPM = @"AM";
                 suggesthour = 12;
             }
             else if (suggesthour < 12){
                 AMPM = @"AM";
             }
             else if (suggesthour == 12){
                 AMPM = @"PM";
             }
             else if (suggesthour < 24){
                 suggesthour = suggesthour - 12;
                 AMPM = @"PM";
             }
             
             _DTS = [NSString stringWithFormat:@"%.02f miles", _distance];
             _DepartTime = [NSString stringWithFormat:@"%02d:%02d %@", suggesthour, suggestmin, AMPM];
             
             
             _Recommended.text = @"Recommended departure time:";
             _DepartureTime.text = _DepartTime;
             _DepartureTime.textColor = [UIColor lightGrayColor];
             _DepartureTime.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:20];
             _DepartureTime.textAlignment = NSTextAlignmentCenter;
         }
             break;
     }
}

- (IBAction)Schedule:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECLeft];
}
@end