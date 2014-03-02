//
//  MyTripViewController.h
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTripViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *fromStation;
@property (strong, nonatomic) IBOutlet UITextField *toStation;
@property (strong, nonatomic) IBOutlet UITextField *startTime;
@property (strong, nonatomic) IBOutlet UITextField *tripTime;

- (IBAction)SaveTripButton:(id)sender;



- (IBAction)backButton:(id)sender;

@property (strong) NSManagedObject *contactdb;


@end
