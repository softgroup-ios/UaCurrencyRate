//
//  GoogleAPIManager.m
//  PrivatBank
//
//  Created by admin on 05.12.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "GoogleAPIManager.h"
#import "AFNetworking/AFNetworking.h"

@interface GoogleAPIManager ()

@property (nonatomic, strong) AFHTTPSessionManager *networkManager;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSMutableArray <NSURLSessionTask*> *tasks;
@end


@implementation GoogleAPIManager

+(GoogleAPIManager*)sharedManager {
    static GoogleAPIManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GoogleAPIManager alloc]init];
        manager.networkManager = [[AFHTTPSessionManager alloc] init];
        manager.networkManager.completionQueue = dispatch_queue_create("com.Exchange.GoogleAPIManager.completionQueue", DISPATCH_QUEUE_CONCURRENT);
        manager.language = @"ru";
        manager.tasks = [NSMutableArray array];
    });
    
    return  manager;
}

- (void)cleanAllResource {
    if (self.tasks) {
        [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        [self.tasks removeAllObjects];
    }
}

#pragma mark - Methods For Get All GoogleAPI

- (void)getReverseGeocoding:(CLLocationCoordinate2D)coord
          completionHandler:(ComplateReversGeo)completionHandler
                 errorBlock:(ErrorBlock)errorBlock {
    
    //https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/geocode/json?";
    NSString *coordString = [NSString stringWithFormat:@"%f,%f", coord.latitude, coord.longitude];
    
    NSDictionary *parameters = @{@"latlng":coordString,
                                 @"language":self.language};
    NSURLSessionTask* task = [self.networkManager GET:directionsAPI parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject:nil;
        if (dict) {
            [self parsePlaceAddress:dict completionHandler:completionHandler errorBlock:errorBlock];
        }
        else {
            errorBlock(nil);
        }
    }  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(error);
    }];
    [self.tasks addObject:task];
}

- (void)getPolylineWithOrigin:(CLLocationCoordinate2D)origin
                  destination:(CLLocationCoordinate2D)destination
            completionHandler:(ComplatePath)completionHandler
                   errorBlock: (ErrorBlock) errorBlock {
    
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    
    NSDictionary *parameters = @{@"origin":originString,
                                 @"destination":destinationString,
                                 @"mode":@"walking",
                                 //@"alternatives":@(YES),
                                 @"key":GoogleApi};
    
    NSURLSessionTask* task = [self.networkManager GET:directionsAPI parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject:nil;
        if (dict) {
            [self parsePolyline:dict completionHandler:completionHandler errorBlock:errorBlock];
        }
        else {
            errorBlock(nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        errorBlock(error);
    }];
    
    [self.tasks addObject:task];
}

- (void)getGeocoding:(NSString*)address
   completionHandler:(ComplateLocation)completionHandler {
    
    //https://maps.googleapis.com/maps/api/geocode/json?address=Центральная,+Чемеровцы,+Украина
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/geocode/json?";
    //NSString *addressString = [address stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSDictionary *parameters = @{@"address":address};
                                // @"key":GoogleApi}; //no needed
    
    NSURLSessionTask* task = [self.networkManager GET:directionsAPI parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [responseObject isKindOfClass:[NSDictionary class]] ? responseObject:nil;
        if (dict) {
            [self parseGeocoding:dict completionHandler:completionHandler];
        }
    } failure:nil];
    
    [self.tasks addObject:task];
}

#pragma mark - Processing result, Parse and other

- (void)parsePlaceAddress:(NSDictionary*)dict
        completionHandler:(ComplateReversGeo)completionHandler
               errorBlock:(ErrorBlock)errorBlock {
    
    NSArray *routesArray = [dict objectForKey:@"results"];
    if (routesArray.count == 0) {
        errorBlock(nil);
        return;
    }

    NSDictionary *foundDict;
    for (NSDictionary *dict in routesArray) {
        NSArray *types = [dict objectForKey:@"types"];
        if ([types containsObject:@"locality"]) {
            foundDict = dict;
        }
    }
    
    if (foundDict) {
        NSArray *addressComponents = [foundDict objectForKey:@"address_components"];
        NSString *cityName = [[addressComponents firstObject] objectForKey:@"long_name"];
        completionHandler(cityName);
    }
    else {
        completionHandler(nil);
    }
}


- (void)parsePolyline:(NSDictionary*)dict
    completionHandler:(ComplatePath)completionHandler
           errorBlock: (ErrorBlock) errorBlock {
    
    NSLog(@"dict: %@",dict);
    NSArray *routesArray = [dict objectForKey:@"routes"];
    
    if ([routesArray count] > 0)
    {
        NSDictionary* routeDict = [routesArray objectAtIndex:0];
        NSDictionary* routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
        NSString* points = [routeOverviewPolyline objectForKey:@"points"];
        GMSPath* path = [GMSPath pathFromEncodedPath: points];
        
        NSArray* legs = [routeDict objectForKey:@"legs"];
        NSDictionary* leg = legs.firstObject;
        NSDictionary* distance = [leg objectForKey:@"distance"];
        NSString* distanceText = [distance objectForKey:@"text"];
        NSDictionary* duration = [leg objectForKey:@"duration"];
        NSString* durationText = [duration objectForKey:@"text"];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(path, distanceText, durationText);
        });
    }
    else
    {
        errorBlock(nil);
    }

}

- (void)parseGeocoding:(NSDictionary*)dict
     completionHandler:(ComplateLocation)completionHandler {
    
    NSString* status = [dict objectForKey:@"status"];
    
    if (![status isEqualToString:@"OK"]) {
        return;
    }
    NSDictionary* resultsDict = [[dict objectForKey:@"results"] firstObject];
    if (!resultsDict) {
        return;
    }
    
    NSDictionary* geometry = [resultsDict objectForKey:@"geometry"];
    if (!geometry) {
        return;
    }
    
    NSDictionary* locationDict = [geometry objectForKey:@"location"];
    if (!geometry) {
        return;
    }
    
    CLLocationDegrees lat = [[locationDict objectForKey:@"lat"] doubleValue];
    CLLocationDegrees lng = [[locationDict objectForKey:@"lng"] doubleValue];
    
    CLLocation* location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    
    if (locationDict) {
        completionHandler(location);
    }
}
@end
