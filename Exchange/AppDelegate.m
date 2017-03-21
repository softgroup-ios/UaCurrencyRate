//
//  AppDelegate.m
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import "AppDelegate.h"
@import GoogleMaps;

#define GoogleApi  @"AIzaSyDx4GFZHF_XYKDtqZEv80P8E85CofbLBLU"





@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:GoogleApi];
    return YES;
}

@end
