//
//  ScheduleViewController.m
//  CanIMakeIt
//
//  Created by Chris on 2014/4/23.
//  Copyright (c) 2014年 Dakshayani Padman. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ECSlidingViewController.h"
#import "DataHelper.h"
#import "Utility.h"

@interface ScheduleViewController ()

@property DataHelper* dataHelper;

@end

@implementation ScheduleViewController

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
    [self.slidingViewController setAnchorLeftRevealAmount:180.0f];
    self.slidingViewController.underRightWidthLayout = ECFullWidth;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.6 green:0.8 blue:1 alpha:1];
    
    self.dataHelper = [[DataHelper alloc] init];
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    NSDate* today = [NSDate date];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *CurrentTime = [outputFormatter stringFromDate:today];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *CurrentDate = [outputFormatter stringFromDate:today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
    [outputFormatter setDateFormat:@"MM-dd"];
    CurrentDate = [outputFormatter stringFromDate:today];
    int tripid = 0;
    
    for (int j  = 0; j < [tripTimes count]; j++) {
        if ([CurrentTime compare:[tripTimes objectAtIndex: j]] == NSOrderedAscending){
            tripid = j;
            break;
        }
        else if ([CurrentTime compare:[tripTimes objectAtIndex:([tripTimes count] - 1)]] == NSOrderedDescending){
            today = [today dateByAddingTimeInterval:60*60*24];
            CurrentDate = [outputFormatter stringFromDate:today];
            date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
            tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
            tripid = 0;
            break;
        }
    }
    
    NSMutableString *a = [NSMutableString string];
    for (int i = tripid; i < [tripTimes count]; i++){
        NSString* nextTrain = [tripTimes objectAtIndex: i];
        [outputFormatter setDateFormat:@"HH:mm:ss"];
        NSDate *nexttrain = [outputFormatter dateFromString:nextTrain];
        NSString *nexttrainhour = [outputFormatter stringFromDate:nexttrain];
        [outputFormatter setDateFormat:@"mm:ss"];
        NSString *nexttrainmin = [outputFormatter stringFromDate:nexttrain];
        [outputFormatter setDateFormat:@"ss"];
        NSString *nexttrainsec = [outputFormatter stringFromDate:nexttrain];
        double nexttraintime = [nexttrainhour doubleValue] * 3600 + [nexttrainmin doubleValue] * 60 + [nexttrainsec doubleValue];
        int suggesthour = nexttraintime / 3600;
        int suggestmin = (nexttraintime - (suggesthour * 3600)) / 60;
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
        NSString *TIME = [NSString stringWithFormat:@"%02d:%02d %@", suggesthour, suggestmin, AMPM];
        [a appendString:TIME];
        [a appendString:@"\n"];
    }
    
    _Date.text = [NSString stringWithFormat:@"%@ Schedule", CurrentDate];
    _Date.textColor = [UIColor darkGrayColor];
    _Date.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:25];
    _Date.textAlignment = NSTextAlignmentCenter;
    
    _TimeV.text = [NSString stringWithFormat:@"%@", a];
    _TimeV.textColor = [UIColor darkGrayColor];
    _TimeV.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:15];
    _TimeV.textAlignment = NSTextAlignmentCenter;
    _TimeV.backgroundColor = [UIColor colorWithRed:0.6 green:0.8 blue:1 alpha:1];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
