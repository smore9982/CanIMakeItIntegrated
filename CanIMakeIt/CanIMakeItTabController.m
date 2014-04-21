//
//  CanIMakeItTabControllerViewController.m
//  CanIMakeIt
//
//  Created by More, Sameer on 4/19/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "CanIMakeItTabController.h"
#import "DataHelper.h"

@interface CanIMakeItTabController ()

@end

@implementation CanIMakeItTabController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DataHelper* dataHelper = [[DataHelper alloc] init];
    int count = [dataHelper getAdvisoryCount];
    [[[[self tabBar] items] objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end