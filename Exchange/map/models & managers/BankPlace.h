//
//  BankPlace.h
//  PrivatBank
//
//  Created by admin on 02.12.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"
@import GoogleMaps;

typedef enum
{
    ATM,
    TSO,
    OFFICE
}TypeOfBankPlaces;


@interface BankPlace : NSObject

@property (nonatomic, strong) NSString* type;
@property (nonatomic, assign) int typeOfEnum;
@property (nonatomic, strong) NSString* fullAddressUa;
@property (nonatomic, strong) NSString* placeUa;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) GMSMarker* marker;


@end
