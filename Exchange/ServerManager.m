//
//  ServerManager.m
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import "ServerManager.h"

@implementation ServerManager


+ (NSMutableArray*)jsonRequestWithUrl:(NSString*)url
{
    NSError *error;
    NSData *jsonData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:url]];
    NSMutableArray *allElements = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return allElements;
}

@end
