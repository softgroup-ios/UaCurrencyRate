//
//  PrivatBankApi.h
//  PrivatBank
//
//  Created by admin on 29.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@class BankPlace;



@protocol GetAllBankPlaceDelegate <NSObject>
- (void)takeBankPlace:(BankPlace*)place;
@end

@interface PrivatBankAPI : NSObject

@property (weak, nonatomic) id <GetAllBankPlaceDelegate> delegate;

- (void)getAllBankPlaceInCity:(NSString*)city
                        myLoc:(CLLocation*)coord
                     inRadius:(CLLocationDistance)distance;

- (void)cleanAllResource;
@end
