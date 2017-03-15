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

@property (nonatomic, strong) dispatch_queue_t apiQueue;
@property (nonatomic, strong) AFHTTPSessionManager* httpManager;

@end


@implementation GoogleAPIManager

+(GoogleAPIManager*) sharedManager
{
    static GoogleAPIManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GoogleAPIManager alloc]init];
        manager.apiQueue = dispatch_queue_create("googleAPI", DISPATCH_QUEUE_SERIAL);
    });
    
    return  manager;
}

#pragma mark - Methods For Get All GoogleAPI

- (void)getReverseGeocoding:(CLLocationCoordinate2D)coord
            completionHandler:(void (^)(NSDictionary *))completionHandler
                   errorBlock: (ErrorBlock) errorBlock
{
    dispatch_async(self.apiQueue, ^{
        [self fetchReverseGeocoding:coord completionHandler:completionHandler errorBlock:errorBlock];
    });
}

- (void)getPolylineWithOrigin:(CLLocationCoordinate2D)origin
                    destination:(CLLocationCoordinate2D)destination
              completionHandler:(void (^)(GMSPath *))completionHandler
                     errorBlock: (ErrorBlock) errorBlock
{
    dispatch_async(self.apiQueue, ^{
        [self fetchPolylineWithOrigin:origin destination:destination completionHandler:completionHandler errorBlock:errorBlock];
    });
}

- (void)getGeocoding:(NSString*) address
     completionHandler:(void (^)(CLLocationCoordinate2D))completionHandler
            errorBlock: (ErrorBlock) errorBlock
{
    dispatch_async(self.apiQueue, ^{
        [self fetchGeocoding:address completionHandler:completionHandler errorBlock:errorBlock];
    });
    
    dispatch_suspend(self.apiQueue);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_resume(self.apiQueue);
    });
}

#pragma mark - Fetch From GoogleAPI Methods

- (void)fetchPolylineWithOrigin:(CLLocationCoordinate2D)origin
                    destination:(CLLocationCoordinate2D)destination
              completionHandler:(void (^)(GMSPath *))completionHandler
                     errorBlock: (ErrorBlock) errorBlock
{
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.latitude, origin.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.latitude, destination.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving&key=%@", directionsAPI, originString, destinationString, GoogleApi];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         errorBlock(error);
                                                         return;
                                                     }
                                                     
                                                     NSArray *routesArray = [json objectForKey:@"routes"];
                                                     
                                                     if ([routesArray count] > 0)
                                                     {
                                                         NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                         NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                         NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             GMSPath* path = [GMSPath pathFromEncodedPath: points];
                                                             if(completionHandler)
                                                             {completionHandler(path);}
                                                         });
                                                     }
                                                     else
                                                     {
                                                         errorBlock(error);
                                                     }
                                                 }];
    [fetchDirectionsTask resume];
}

- (void)fetchReverseGeocoding:(CLLocationCoordinate2D)coord
            completionHandler:(void (^)(NSDictionary *))completionHandler
                   errorBlock: (ErrorBlock) errorBlock
{
    
    //https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=
    
    NSString *coordString = [NSString stringWithFormat:@"%f,%f", coord.latitude, coord.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/geocode/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&latlng=%@&language=ru", directionsAPI, coordString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         errorBlock(error);
                                                         return;
                                                     }
                                                     
                                                     NSArray* routesArray = [json objectForKey:@"results"];
                                                     if (routesArray.count <= 0)
                                                     {
                                                         errorBlock(nil);
                                                         return;
                                                     }
                                                     
                                                     NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
                                                     for (NSDictionary* dict in routesArray)
                                                     {
                                                         NSArray* types = [dict objectForKey:@"types"];
                                                         if ([types containsObject:@"locality"])
                                                         {
                                                             NSArray* addressComponents = [dict objectForKey:@"address_components"];
                                                             NSDictionary* cityName = [[addressComponents firstObject] objectForKey:@"long_name"];
                                                             [tempDict setObject:cityName forKey:@"city"];
                                                         }
                                                         else if ([types containsObject:@"country"])
                                                         {
                                                             [tempDict setObject:[dict objectForKey:@"formatted_address"] forKey:@"country"];
                                                         }
                                                     }
                                                     
                                                     completionHandler(tempDict);
                                                     
                                                 }];
    
    [fetchDirectionsTask resume];
}

- (void)fetchGeocoding:(NSString*) address
     completionHandler:(void (^)(CLLocationCoordinate2D))completionHandler
            errorBlock: (ErrorBlock) errorBlock
{
    //https://maps.googleapis.com/maps/api/geocode/json?address=Центральная,+Чемеровцы,+Украина
    
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/geocode/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&address=%@&key=%@", directionsAPI, address,GoogleApi];
    
    directionsUrlString = [directionsUrlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        
        if((error)||(!data))
        {
            errorBlock(error);
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if(error)
        {
            errorBlock(error);
            return;
        }
        
        NSString* status = [json objectForKey:@"status"];
        
        if (![status isEqualToString:@"OK"])
        {
            errorBlock(nil);
            return;
        }
        NSDictionary* dict = [[json objectForKey:@"results"] firstObject];
        if (!dict)
        {
            errorBlock(nil);
            return;
        }
        
        NSDictionary* geometry = [dict objectForKey:@"geometry"];
        if (!geometry)
        {
            errorBlock(nil);
            return;
        }
        
        NSDictionary* location = [geometry objectForKey:@"location"];
        if (!geometry)
        {
            errorBlock(nil);
            return;
        }
        
        double lat = [[location objectForKey:@"lat"] doubleValue];
        double lng = [[location objectForKey:@"lng"] doubleValue];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
        
        if (lat&&lng)
        {
            completionHandler(coord);
        }
        
   }];
    [fetchDirectionsTask resume];

}

@end
