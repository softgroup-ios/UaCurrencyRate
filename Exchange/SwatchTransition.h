//
//  SwatchTransition.h
//  Exchange
//
//  Created by Max Ostapchuk on 3/2/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SwatchTransitionMode){
    SwatchTransitionModePresent = 0,
    SwatchTransitionModeDismiss
};

@interface SwatchTransition : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) SwatchTransitionMode mode;

@end
