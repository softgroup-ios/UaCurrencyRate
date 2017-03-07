//
//  ServerManager.m
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import "ServerManager.h"
#import "СurrencyModel.h"


@implementation ServerManager


+ (void) downloadCurrentModelsWithSuccessBlock: (SuccessDownloadCurrency) successBlock{
    
    NSURL *url = [NSURL URLWithString:@"https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError * error) {
        
        if (!data||error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(nil);
                NSLog(@"%@",error);
            });
            return;
        }
        
        NSMutableArray *arrayWithModels = [NSMutableArray new];
        NSMutableArray *allElements = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        for(NSDictionary *jsonModel in allElements){
            CurrencyModel *model = [CurrencyModel new];
            model.exchangeToCurrency = [jsonModel objectForKey:@"ccy"];
            model.buyRate = [[jsonModel objectForKey:@"buy"] floatValue];
            model.sellRate = [[jsonModel objectForKey:@"sale"] floatValue];
            [arrayWithModels addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(arrayWithModels);
        });
    }] resume];
}

+ (void) downloadYesterdayModelsWithData:(NSString*)date
                     andWithSuccessBlock:(SuccessDownloadCurrency) successBlock{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.privatbank.ua/p24api/exchange_rates?json&date=%@",date]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError * error) {
        
        if (!data||error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(nil);
            });
            return;
        }
        
        NSMutableArray *unsortedModelsArray = [NSMutableArray new];
        NSDictionary *allElements = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        NSArray *exchangeRate = [allElements objectForKey:@"exchangeRate"];
        for(NSDictionary *jsonModel in exchangeRate){            
            CurrencyModel *model = [CurrencyModel new];
            model.exchangeToCurrency = [jsonModel objectForKey:@"currency"];
            model.buyRate = [[jsonModel objectForKey:@"purchaseRateNB"] floatValue];
            model.sellRate = [[jsonModel objectForKey:@"saleRateNB"] floatValue];
            [unsortedModelsArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            successBlock(unsortedModelsArray);
        });
    }] resume];
}

@end
