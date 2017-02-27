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

+(NSMutableArray*)getCurrencyModels{
    
    NSMutableArray *arrayWithModels = [NSMutableArray new];
    NSArray *recievedJSONArray = [ServerManager jsonRequestWithUrl:@"https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"];
    for(NSDictionary *jsonModel in recievedJSONArray){
        
        CurrencyModel *model = [CurrencyModel new];
        model.exchangeToCurrency = [jsonModel objectForKey:@"ccy"];
        model.buyRate = [[jsonModel objectForKey:@"buy"] floatValue];
        model.sellRate = [[jsonModel objectForKey:@"sale"] floatValue];
        [arrayWithModels addObject:model];
    }
    return arrayWithModels;
}

+(NSArray*)getYesterdayCurrencyModels{
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -345600.0];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy"];
    NSString *dateString = [dateFormat stringFromDate:yesterday];
    NSMutableArray *unsortedModelsArray = [NSMutableArray new];
    NSDictionary *recievedJSONArray = [ServerManager jsonRequestWithUrl:[NSString stringWithFormat:@"https://api.privatbank.ua/p24api/exchange_rates?json&date=%@",dateString]];
    NSArray *exchangeRate = [recievedJSONArray objectForKey:@"exchangeRate"];
    for(NSDictionary *jsonModel in exchangeRate){
        
        CurrencyModel *model = [CurrencyModel new];
        model.exchangeToCurrency = [jsonModel objectForKey:@"currency"];
        model.buyRate = [[jsonModel objectForKey:@"purchaseRateNB"] floatValue];
        model.sellRate = [[jsonModel objectForKey:@"saleRateNB"] floatValue];
        [unsortedModelsArray addObject:model];
    }
    NSArray *resultArray = [self getNeededModels:unsortedModelsArray];
    return resultArray;
}

+(NSArray*)getNeededModels:(NSArray*)firstArray{
    
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
