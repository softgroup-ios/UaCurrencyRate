//
//  ServerManager.m
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import "ServerManager.h"


@implementation ServerManager



+ (NSMutableArray*)jsonRequestWithUrl:(NSString*)url{

    NSMutableArray *allElements = [NSMutableArray new];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
    NSURLResponse *response;
    NSError *error;
    
    NSURLSessionDataTask *aData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (aData) {
        
        allElements = (NSMutableArray*)[NSJSONSerialization JSONObjectWithData:aData options:kNilOptions error:&error];
        
        NSLog(@"jsonReturn %@",allElements);
    }
    return allElements;
}

@end
