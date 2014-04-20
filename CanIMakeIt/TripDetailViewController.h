//
//  TripDetailViewController.h
//  CanIMakeIt
//
//  Created by DAKSHAYANI PADMAN on 3/15/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *fromStationLabel;
@property (strong, nonatomic) IBOutlet UILabel *toStationLabel;
@property (strong, nonatomic) IBOutlet UILabel *transferStationLabel;
@property (strong, nonatomic) IBOutlet UILabel *agencyLabel;

@property (strong, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

- (IBAction)setDefaultTripButton:(id)sender;
- (IBAction)updateTrip:(id)sender;

@property (strong) NSManagedObject *contactdb;

@end
