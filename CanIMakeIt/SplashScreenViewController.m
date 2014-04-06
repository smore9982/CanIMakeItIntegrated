//
//  SplashScreenViewController.m
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "DataHelper.h"

@interface SplashScreenViewController ()
@property DataHelper* dataHelper;
@end

@implementation SplashScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataHelper = [[DataHelper alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if([self.dataHelper isFirstLaunch]){
        //Load Agencies then load stops
        [self.dataHelper loadAgencies:^(NSString* str){
            NSArray* agencies = [self.dataHelper getAgencyNames];

            [self.dataHelper loadStops:^(NSString* str){
                
                [self.dataHelper setFirstLaunch:true];
                [self performSegueWithIdentifier:@"SplashToWelcomeSegue" sender:self];
                return;
            }error:^(NSString * str) {
                NSLog(@"Inside Completion Handler");
                return;
            }];
        }error:^(NSString* str){
            return;
        }];
        return;
    }
    
    TripProfileModel* tripProfileModel =[self.dataHelper getDefaultProfileData];
    if(tripProfileModel == nil){
        [self performSegueWithIdentifier:@"SplashToTripsSegue" sender:self];
        return;
    }
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    NSDate * now = [NSDate date];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    //This is where to set the leaving time:
    NSDate * starttime = [outputFormatter dateFromString:tripProfileModel.departureTime];
    NSString *StartTime = [outputFormatter stringFromDate:starttime];
    NSString *CurrentTime = [outputFormatter stringFromDate:now];
    if ([CurrentTime compare:StartTime] == NSOrderedDescending) {
        [self performSegueWithIdentifier:@"SplashToTimerSegue" sender:self];
        
    } else if ([CurrentTime compare:StartTime] == NSOrderedAscending) {
        [self performSegueWithIdentifier:@"SplashToTripsSegue" sender:self];
        
    } else {
        [self performSegueWithIdentifier:@"SplashToTimerSegue" sender:self];
        
    }
    return;
    
    
}

-(BOOL) isTimerRunning{
    return false;
}

@end
