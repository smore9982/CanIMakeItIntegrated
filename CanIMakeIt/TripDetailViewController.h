//
//  TripDetailViewController.h
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/15/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *fromStationLabel;
@property (strong, nonatomic) IBOutlet UILabel *toStationLabel;
@property (strong, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripTimeLabel;

- (IBAction)setDefaultTripButton:(id)sender;



@property (strong) NSManagedObject *contactdb;

@end
