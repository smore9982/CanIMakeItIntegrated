//
//  CanIMakeItTabControllerViewController.h
//  CanIMakeIt
//
//  Created by More, Sameer on 4/19/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanIMakeItTabController : UITabBarController
- (void) updateAdvisoryCount: (void (^) (UIBackgroundFetchResult)) completionHandler;
@end
