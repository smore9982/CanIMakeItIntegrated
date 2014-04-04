//
//  MyTripViewController.h
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTripViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *fromStation;
@property (strong, nonatomic) IBOutlet UITextField *toStation;
@property (strong, nonatomic) IBOutlet UITextField *transferStation;

@property (strong, nonatomic) IBOutlet UITextField *tripTime;
@property (strong, nonatomic) IBOutlet UITextField *startTime;
@property (strong, nonatomic) IBOutlet UIPickerView *currentPicker;
@property (strong, nonatomic) UITextField *currentTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *progressIcon;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveTripButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;


@property (strong) NSManagedObject *contactdb;

@end
