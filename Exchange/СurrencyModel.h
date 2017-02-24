//
//  СurrencyModel.h
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyModel : NSObject

@property(strong,nonatomic) NSString *exchangeToCurrency;
@property(nonatomic,assign) float buyRate;
@property(nonatomic,assign) float sellRate;

+(NSMutableArray*)getCurrencyModels;
+(NSArray*)getYesterdayCurrencyModels;
+(NSArray*)getNeededModels:(NSArray*)firstArray;

@end
