//
//  ViewController.h
//  Timer
//
//  Created by Chris on 2014/2/27.
//  Copyright (c) 2014年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController
- (IBAction)Start:(id)sender;
- (IBAction)Stop:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *WatchLabel;
@property (strong, nonatomic) NSTimer *stopWatchTimer; // Store the timer that fires after a certain time
@property (strong, nonatomic) NSDate *startDate; // Stores the date of the click on the start button
@property (weak, nonatomic) IBOutlet UITextField *SetTime;
@property NSInteger counter;
@property UIApplication *app;
@property (strong, nonatomic) IBOutlet UILabel *NextTrainTime;
- (IBAction)SkipTrain:(id)sender;

@end
