//
//  TripProfileViewController.h
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripProfileViewController : UITableViewController

@property (strong) NSMutableArray *tripArray;
@property (strong, nonatomic) NSManagedObject *contactdb;

@end
