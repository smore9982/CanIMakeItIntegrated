//
//  SplashScreenViewController.m
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "SplashScreenViewController.h"
@implementation SplashScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    if([self isFirstLaunch]){
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

- (BOOL) isFirstLaunch
{
    //Check UserData check if this is a first launch.
    return true;
}

-(BOOL) isTimerRunning{
    
    // Check if the tmer is running or if we are after the default trip time.
    return false;
}

@end
