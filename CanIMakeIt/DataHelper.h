//
//  DataHelper.h
//  CanIMakeIt
//
//  Created by More, Sameer on 3/8/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHelper : NSObject
- (NSString *) getUserData : (NSString*) key;
- (BOOL) saveUserData : (NSString*) key withValue: (NSString*) value;
- (BOOL) isFirstLaunch;
- (BOOL) setFirstLaunch : (BOOL) isFirstLaunch;
@end
