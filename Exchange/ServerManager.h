//
//  ServerManager.h
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface ServerManager : NSObject

+ (NSMutableArray*)jsonRequestWithUrl:(NSString*)url;

@end
