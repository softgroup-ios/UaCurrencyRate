//
//  PrivatBankApiManager.m
//  PrivatBank
//
//  Created by admin on 29.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PrivatBankApiManager.h"
#import "AFNetworking/AFNetworking.h"
#import "BankPlace.h"
#import "GoogleAPIManager.h"
#import "MapKit/MapKit.h"

@interface PrivatBankApiManager () <NSXMLParserDelegate>

@property (nonatomic, strong) dispatch_queue_t apiQueue;
@property (nonatomic, strong) AFHTTPSessionManager* httpManager;
@property (nonatomic, strong) NSMutableSet <NSDictionary*>* setOfDict;

@property (nonatomic, strong) NSDictionary* tempDict;
@property (nonatomic, strong) GoogleAPIManager* googleAPIManager;

@end

@implementation PrivatBankApiManager

+(PrivatBankApiManager*) sharedManager
{
    static PrivatBankApiManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PrivatBankApiManager alloc]init];
        manager.apiQueue = dispatch_queue_create("PrivatBankAPIQueue", DISPATCH_QUEUE_SERIAL);
        manager.httpManager = [AFHTTPSessionManager manager];
        manager.googleAPIManager = [GoogleAPIManager sharedManager];
    });
    
    return  manager;
}



#pragma mark - Manager Methods

-(void) getAllBankPlaceInCity: (NSString*) city
                    orAddress: (NSString*) address
            WithComplateBlock: (ComplateBlock) complateBlock
                   errorBlock: (ErrorBlock) errorBlock
{
    NSDictionary* dict = @{@"ComplateBlock":complateBlock,
                           @"ErrorBlock":errorBlock};
    
    dispatch_async(self.apiQueue, ^{
        [self allBankPlaces:dict city:city address:address];
    });
}
-(void) getExchangeRatesWithComplateBlock: (ComplateBlock) complateBlock
                               errorBlock: (ErrorBlock) errorBlock
{
    
    NSDictionary* dict = @{@"ComplateBlock":complateBlock,
                           @"ErrorBlock":errorBlock};
    
    dispatch_async(self.apiQueue, ^{
        [self exchangeRatesAPIWithDict: dict];
    });
}

-(void) getExchangeRatesNBYWithComplateBlock: (ComplateBlock) complateBlock
                               errorBlock: (ErrorBlock) errorBlock
{
    
    NSDictionary* dict = @{@"ComplateBlock":complateBlock,
                           @"ErrorBlock":errorBlock};
    
    dispatch_async(self.apiQueue, ^{
        [self exchangeRatesNBYAPIWithDict: dict];
    });
}

#pragma mark - Main Get Methods

- (void) allBankPlaces: (NSDictionary*) dict city:(NSString*) city address: (NSString*) address
{
    NSString* getTSO = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/infrastructure?json&tso&address=%@&city=%@",address ? address : @"", city ? city : @""];
    NSString* getATM = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/infrastructure?json&atm&address=%@&city=%@",address ? address : @"", city ? city : @""];
    NSString* pboffice = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/pboffice?json&address=%@&city=%@", address ? address : @"", city ? city : @""];
    
    getTSO = [getTSO stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    getATM = [getATM stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    pboffice = [pboffice stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self.httpManager GET:pboffice parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (responseObject)
         {
             [self parseOffice:responseObject withBlocks:dict];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         ErrorBlock errorBlock = [dict objectForKey:@"ErrorBlock"];
         errorBlock(nil);
     }];
    
    [self.httpManager GET:getTSO parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (responseObject)
         {
             [self parseBankomat:responseObject withBlocks: dict];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         ErrorBlock errorBlock = [dict objectForKey:@"ErrorBlock"];
         errorBlock(nil);
     }];
    
    [self.httpManager GET:getATM parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
     {
         
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         if (responseObject)
         {
             [self parseBankomat:responseObject withBlocks: dict];
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         ErrorBlock errorBlock = [dict objectForKey:@"ErrorBlock"];
         errorBlock(nil);
     }];
}

- (void) exchangeRatesNBYAPIWithDict: (NSDictionary*) dict
{
    NSString* urlString = [NSString stringWithFormat:@"https://privat24.privatbank.ua/p24/accountorder?oper=prp&PUREXML&apicour&country=ua&full"];
    NSURL* url = [NSURL URLWithString:urlString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if (error)
          {
              return;
          }
          if (data)
          {
              self.tempDict = nil;
              self.tempDict = dict;
              NSXMLParser* parser = [[NSXMLParser alloc]initWithData:data];
              parser.delegate = self;
              [parser parse];
          }
      }] resume];
}

- (void) exchangeRatesAPIWithDict: (NSDictionary*) dict
{
    NSString* urlString = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"];

    [self.httpManager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress)
    {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        if (responseObject)
        {
            [self parseDict:responseObject withBlocks: dict];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        ErrorBlock errorBlock = [dict objectForKey:@"ErrorBlock"];
        errorBlock(nil);
    }];
}

#pragma mark - Help methods

- (void) parseDict: (id) parseData withBlocks: (NSDictionary*) dict
{
    if(![self checkIf:parseData isClass:[NSArray class]])
    {return;}
    
    NSMutableSet* tempSet = [NSMutableSet set];
    for (NSDictionary* dict in parseData)
    {
        if(![self checkIf:dict isClass:[NSDictionary class]])
        {return;}
        
        NSString* from = [dict objectForKey:@"ccy"];
        NSString* buy = [dict objectForKey:@"buy"];
        NSString* sell = [dict objectForKey:@"sale"];
        
        if (!from||!buy||!sell)
        {
            continue;
        }
        
        NSString* answer = [NSString stringWithFormat:@"%@ BUY: %@ SELL: %@",from, buy,sell];
        [tempSet addObject:answer];
    }
    
    if (!tempSet)
    {
        NSString* errorDomain = @"Nill in answer";
        NSError* error = [NSError errorWithDomain:errorDomain code:2 userInfo:nil];
        
        ErrorBlock errorBlock = [dict objectForKey:@"ErrorBlock"];
        errorBlock(error);
        return;
    }
    ComplateBlock complate = [dict objectForKey:@"ComplateBlock"];
    complate(tempSet);
}

- (void) parseBankomat: (id) parseData withBlocks: (NSDictionary*) dict
{
    if(![self checkIf:parseData isClass:[NSDictionary class]])
    {return;}
    
    NSArray* arrayOfPlace = [parseData objectForKey:@"devices"];
    if(![self checkIf:arrayOfPlace isClass:[NSArray class]])
    {return;}
    
    NSMutableSet<BankPlace*>* tempSet = [NSMutableSet set];
    for (NSDictionary* dict in arrayOfPlace)
    {
        if(![self checkIf:dict isClass:[NSDictionary class]])
        {return;}
        
        NSString* type = [dict objectForKey:@"type"];
        NSString* fullAddressUa = [dict objectForKey:@"fullAddressUa"];
        NSString* placeUa = [dict objectForKey:@"placeUa"];
        NSString* latitude = [dict objectForKey:@"latitude"];
        NSString* longitude = [dict objectForKey:@"longitude"];
        
        BankPlace* place = [[BankPlace alloc]init];
        place.type = type;
        place.fullAddressUa = fullAddressUa;
        place.placeUa = placeUa;
        place.coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);

        [tempSet addObject:place];
    }
    
    if (!tempSet)
    {
        NSString* errorDomain = @"Nill in answer";
        NSError* error = [NSError errorWithDomain:errorDomain code:2 userInfo:nil];
        
        ErrorBlock errorBlock = [dict objectForKey:@"ErrorBlock"];
        errorBlock(error);
        return;
    }
    ComplateBlock complate = [dict objectForKey:@"ComplateBlock"];
    complate(tempSet);
}

- (void) parseOffice: (id) parseData withBlocks: (NSDictionary*) dict
{
    if(![self checkIf:parseData isClass:[NSArray class]])
    {return;}
    
    NSMutableSet<BankPlace*>* tempSet = [NSMutableSet set];
    
    for (NSDictionary* dict in parseData)
    {
        if(![self checkIf:dict isClass:[NSDictionary class]])
        {return;}
        
        NSString* type = @"OFFICE";
        NSString* placeUa = [dict objectForKey:@"name"];
        
        NSString* address = [dict objectForKey:@"address"];
        NSString* city = [dict objectForKey:@"city"];
        NSString* state = [dict objectForKey:@"state"];
        NSString* country = [dict objectForKey:@"country"];
        
        NSString* fullAddressUa = [NSString stringWithFormat:@"%@, %@, %@, %@",address,city,state,country];
        
        BankPlace* place = [[BankPlace alloc]init];
        place.type = type;
        place.fullAddressUa = fullAddressUa;
        place.placeUa = placeUa;
        
        
        [self.googleAPIManager getGeocoding:fullAddressUa completionHandler:^(CLLocationCoordinate2D coord)
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                place.coordinate = coord;
            });
            
        } errorBlock:^(NSError* error)
        {
            
        }];
        
        [tempSet addObject:place];
    }
    
    if (!tempSet)
    {
        NSString* errorDomain = @"Nill in answer";
        NSError* error = [NSError errorWithDomain:errorDomain code:2 userInfo:nil];
        
        ErrorBlock errorBlock = [dict objectForKey:@"ErrorBlock"];
        errorBlock(error);
        return;
    }
    ComplateBlock complate = [dict objectForKey:@"ComplateBlock"];
    complate(tempSet);
}


- (BOOL) checkIf:(id) obj isClass:(Class) class
{
    if (![obj isKindOfClass:class])
    {
        return NO;
    }
    return YES;
}

#pragma mark - XML Parser methods <NSXMLParserDelegate>

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.setOfDict = nil;
    self.setOfDict = [NSMutableSet set];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (self.setOfDict&&self.tempDict)
    {
        ComplateBlock complate = [self.tempDict objectForKey:@"ComplateBlock"];
        complate(self.setOfDict);
    }
    else
    {
        ErrorBlock errorBlock = [self.tempDict objectForKey:@"ErrorBlock"];
        errorBlock(nil);
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    if ([attributeDict allKeys].count > 1)
    {
        [self.setOfDict addObject:attributeDict];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName
{
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
}
@end
