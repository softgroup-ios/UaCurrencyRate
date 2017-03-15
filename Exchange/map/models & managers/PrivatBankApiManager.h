//
//  PrivatBankApiManager.h
//  PrivatBank
//
//  Created by admin on 29.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ComplateBlock)(NSSet*);
typedef void (^ErrorBlock)(NSError*);

@interface PrivatBankApiManager : NSObject

+(PrivatBankApiManager*) sharedManager;

-(void) getExchangeRatesWithComplateBlock: (ComplateBlock) complateBlock
                               errorBlock: (ErrorBlock) errorBlock;

-(void) getExchangeRatesNBYWithComplateBlock: (ComplateBlock) complateBlock
                                  errorBlock: (ErrorBlock) errorBlock;

-(void) getAllBankPlaceInCity: (NSString*) city
                    orAddress: (NSString*) address
            WithComplateBlock: (ComplateBlock) complateBlock
                   errorBlock: (ErrorBlock) errorBlock;
@end
