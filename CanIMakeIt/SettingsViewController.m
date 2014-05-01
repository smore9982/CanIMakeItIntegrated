//
//  SettingsViewController.m
//  CanIMakeIt
//
//  Created by More, Sameer on 4/16/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "SettingsViewController.h"
#import "DataHelper.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"Loading settings");
    self.view.backgroundColor = [UIColor colorWithRed:0.226394 green:0.696649 blue:1.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateData:(id)sender {
    DataHelper* dataHelper = [[DataHelper alloc]init];
    [dataHelper loadAgencies:^(NSString* str){
        [dataHelper loadStops:^(NSString* str){
            NSLog(@"Finished loading stops");
            return;
        }error:^(NSString * str) {
            NSLog(@"Inside Completion Handler");
            return;
        }];
    }error:^(NSString* str){
        return;
    }];
}
@end
