//
//  GoogleAPIManager.h
//  PrivatBank
//
//  Created by admin on 05.12.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

#define GoogleApi  @"AIzaSyDx4GFZHF_XYKDtqZEv80P8E85CofbLBLU"

typedef void (^ErrorBlock)(NSError*);


@interface GoogleAPIManager : NSObject



+(GoogleAPIManager*) sharedManager;

- (void)getPolylineWithOrigin:(CLLocationCoordinate2D)origin
                    destination:(CLLocationCoordinate2D)destination
              completionHandler:(void (^)(GMSPath *))completionHandler
                     errorBlock: (ErrorBlock) errorBlock;

- (void)getReverseGeocoding:(CLLocationCoordinate2D)coord
            completionHandler:(void (^)(NSDictionary *))completionHandler
                   errorBlock: (ErrorBlock) errorBlock;

- (void)getGeocoding:(NSString*) address
     completionHandler:(void (^)(CLLocationCoordinate2D))completionHandler
            errorBlock: (ErrorBlock) errorBlock;

@end
