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
    StopModel* departureStation = [self.dataHelper getStopModelWithID:tripProfileModel.departureId];
    StopModel* destinationStation = [self.dataHelper getStopModelWithID:tripProfileModel.destinationId];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    NSDate* today = [NSDate date];
    [outputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *CurrentDate = [outputFormatter stringFromDate:today];
    NSDate* date = [Utility stringToDateConversion:CurrentDate withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:tripProfileModel.departureId DestinationID:tripProfileModel.destinationId onDate:date];
    [outputFormatter setDateFormat:@"MM-dd"];
    CurrentDate = [outputFormatter stringFromDate:today];
    //NSLog(@"%@", CurrentDate);
    //NSLog(@"%@", tripTimes);
    
    NSMutableString *a = [NSMutableString string];
    for (int i = 0; i < [tripTimes count]; i++){
    [a appendString:[tripTimes objectAtIndex: i]];
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
