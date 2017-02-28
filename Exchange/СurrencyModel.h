//
//  СurrencyModel.h
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyModel : NSObject

typedef void(^modelsBlock)(NSMutableArray *array);

@property(strong,nonatomic) NSString *exchangeToCurrency;
@property(nonatomic,assign) float buyRate;
@property(nonatomic,assign) float sellRate;

+(void)getCurrencyModels:(modelsBlock)completionBlock;
+(void)getYesterdayCurrencyModels:(modelsBlock)completionBlock;
+(NSMutableArray*)getNeededModels:(NSArray*)firstArray;

@end
