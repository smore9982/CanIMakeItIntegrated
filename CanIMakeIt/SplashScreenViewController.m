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
        [self.dataHelper setFirstLaunch:true];
        [self performSegueWithIdentifier:@"SplashToWelcomeSegue" sender:self];
        return;
    }
    
    if([self isTimerRunning]){
        [self performSegueWithIdentifier:@"SplashToTimerSegue" sender:self];
    }else{
        [self performSegueWithIdentifier:@"SplashToTripsSegue" sender:self];
    }
    return;
    
    
}

-(BOOL) isTimerRunning{
    return false;
}


@end
