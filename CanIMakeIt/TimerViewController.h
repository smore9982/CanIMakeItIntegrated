//
//  ViewController.h
//  Timer
//
//  Created by Chris on 2014/2/27.
//  Copyright (c) 2014年 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface TimerViewController : UIViewController <CLLocationManagerDelegate, UIActionSheetDelegate>
- (IBAction)Stop:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *WatchLabel;
@property (strong, nonatomic) NSTimer *stopWatchTimer;
@property (strong, nonatomic) NSTimer *RecordTimer;
@property (strong, nonatomic) NSDate *startDate;
@property NSInteger counter;
@property UIApplication *app;
@property (strong, nonatomic) IBOutlet UILabel *NextTrainTime;
- (IBAction)SkipTrain:(id)sender;
@property CLLocationManager *locationManager;

- (IBAction)ResetTimer:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *TripDetailLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *ProgressToStation;
@property (weak, nonatomic) IBOutlet UILabel *distanceToStop;

-(IBAction)showActionSheet:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *DepartureTime;
@property (strong, nonatomic) IBOutlet UILabel *Recommended;
- (IBAction)Schedule:(id)sender;

@end
