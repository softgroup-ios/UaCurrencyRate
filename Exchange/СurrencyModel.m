//
//  СurrencyModel.m
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import "СurrencyModel.h"
#import "ServerManager.h"

@implementation CurrencyModel

+(void)getCurrencyModels:(modelsBlock)completionBlock{
    
    [ServerManager downloadCurrentModelsWithsuccessBlock:^(NSMutableArray *models) {
        if(models){
            completionBlock(models);
        }else{
            completionBlock(nil);
        }
    }];
}

+(void)getYesterdayCurrencyModels:(modelsBlock)completionBlock{
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -345600.0];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSString *dateString = [dateFormat stringFromDate:yesterday];
    
    [ServerManager downloadYesterdayModelsWithData:dateString andWithsuccessBlock:^(NSMutableArray *models) {
        if(models){
            NSMutableArray *resultArray = [self getNeededModels:models];
            completionBlock(resultArray);
        }else{
            completionBlock(nil);
        }
    }];
}

+(NSMutableArray*)getNeededModels:(NSArray*)firstArray{
    
    NSMutableArray *sortedModelsArray = [NSMutableArray new];
    for(CurrencyModel *model in firstArray){
        if([model.exchangeToCurrency  isEqual: @"EUR"]){
            [sortedModelsArray addObject:model];
        }else
            if([model.exchangeToCurrency  isEqual: @"USD"]){
                [sortedModelsArray addObject:model];
            }else
                if([model.exchangeToCurrency  isEqual: @"RUB"]){
                    [sortedModelsArray addObject:model];
                }
    }
    return sortedModelsArray;
}



@end
