//
//  BankPlace.m
//  PrivatBank
//
//  Created by admin on 02.12.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "BankPlace.h"


@implementation BankPlace

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate {
    static UIImageView* bankomatLogo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //set marker icon
        bankomatLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"marker"]];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            bankomatLogo.bounds = CGRectMake(0, 0, 20, 20);
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            bankomatLogo.bounds = CGRectMake(0, 0, 30, 30);
        }
    });
    
    _coordinate = coordinate;
    self.marker = [[GMSMarker alloc]init];
    self.marker.position = coordinate;
    self.marker.title = self.placeUa;
    self.marker.snippet = self.fullAddressUa;
    self.marker.iconView = bankomatLogo;
    self.marker.userData = [NSNumber numberWithInt:self.typeOfEnum];
    self.marker.tracksInfoWindowChanges = YES;
}

- (void) setType:(NSString *)type {
    _type = type;
    
    if ([type isEqualToString:@"TSO"]) {
        self.typeOfEnum = TSO;
    }
    else if ([type isEqualToString:@"ATM"]) {
        self.typeOfEnum = ATM;
    }
    else if ([type isEqualToString:@"OFFICE"]) {
        self.typeOfEnum = OFFICE;
    }

}

@end
