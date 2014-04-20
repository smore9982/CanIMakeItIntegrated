//
//  AdvisoryViewController.h
//  CanIMakeIt
//
//  Created by More, Sameer on 4/16/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataHelper.h"
#import "AdvisoryModel.h"

@interface AdvisoryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *advisoryTable;
@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) NSArray *items1;
@property (strong, nonatomic) DataHelper *dataHelper;

@end
