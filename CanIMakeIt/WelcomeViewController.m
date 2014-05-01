//
//  WelcomeViewController.m
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "WelcomeViewController.h"
#import "DataHelper.h"
#import "Utility.h"

@interface WelcomeViewController ()
@property DataHelper* dataHelper;
@end

@implementation WelcomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.226394 green:0.696649 blue:1.0 alpha:1.0];
    /*
    self.dataHelper = [[DataHelper alloc] init];
    [self.dataHelper saveTripDepartureTimesWithDepartureId:@"8" DestionstionID:@"55"
        completion:^(NSString* str){
            [self.welcomeText setText:@"IT WOOOORRRKRKRKKRR"];
            return;
        }
     
        error:^(NSString * str) {
            NSLog(@"Inside Completion Handler");
            return;
        }
     ];
    
    NSDate* date = [Utility stringToDateConversion:@"2014-03-15" withFormat:@"yyyy-MM-dd"];
    NSArray* tripTimes = [self.dataHelper getTripDepartureTimesForDepartureId:@"8" DestinationID:@"55" onDate:date];
    NSArray* stops = [self.dataHelper getStopsForAgency:@"LIRR"];
    for(int i=0;i<[stops count];i++){
        NSLog([[stops objectAtIndex:i] valueForKey:@"stopName"]);
    }
    NSLog(@"HI");*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
