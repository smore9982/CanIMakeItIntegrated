//
//  MyTripViewController.h
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTripViewController : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UITextField *fromStation;
@property (strong, nonatomic) IBOutlet UITextField *toStation;
@property (strong, nonatomic) IBOutlet UIPickerView *startTimePicker;
@property (strong, nonatomic) IBOutlet UITextField *tripTime;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveTripButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;


@property (strong) NSManagedObject *contactdb;

@end
