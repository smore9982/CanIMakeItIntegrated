//
//  ViewController.m
//  Timer
//
//  Created by Chris on 2014/2/27.
//  Copyright (c) 2014年 Chris. All rights reserved.
//

#import "TimerViewController.h"
#import "AppDelegate.h"

@interface TimerViewController ()

@property NSNumber *myNumber;
@property BOOL countdowning;
@property UILocalNotification *notification;
@property AppDelegate *appDelegate;

@end

@implementation TimerViewController

- (void)viewDidLoad
{
    _appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    _notification = [[UILocalNotification alloc] init];
    _app = [UIApplication sharedApplication];
    _countdowning = TRUE;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Start:(id)sender {
    if (_countdowning == TRUE) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        _myNumber = [f numberFromString:self.SetTime.text];
        _counter = [_myNumber integerValue];
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
    _counter = _counter - 1;
    _appDelegate.counter = _appDelegate.counter - 1;
    int minutes = _counter / 60;
    int seconds = _counter - (minutes * 60);
    self.WatchLabel.text = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    if (_counter == 0) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        _myNumber = [f numberFromString:self.SetTime.text];
        _counter = [_myNumber integerValue];
        _appDelegate.counter = _counter;
    }
    else if (_counter >10){
        self.view.backgroundColor = [UIColor whiteColor];
    }
    else if (_counter == 10){
        if (_notification)
        {
            _notification.repeatInterval = 0;
            _notification.alertBody = @"You should leave now!!";
            [_app presentLocalNotificationNow:_notification];
        }
    }
    else if (_counter <= 10 && _counter > 5){
        self.view.backgroundColor = [UIColor yellowColor];
    }
    else if (_counter == 5){
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

@end
