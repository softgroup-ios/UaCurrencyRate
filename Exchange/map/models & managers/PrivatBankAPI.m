//
//  PrivatBankApiManager.m
//  PrivatBank
//
//  Created by admin on 29.11.16.
//  Copyright © 2016 admin. All rights reserved.
//

#import "PrivatBankAPI.h"
#import "AFNetworking/AFNetworking.h"
#import "BankPlace.h"
#import "GoogleAPIManager.h"




@interface PrivatBankAPI ()
@property (nonatomic, strong) AFHTTPSessionManager* networkManager;
@property (nonatomic, strong) GoogleAPIManager* googleAPIManager;
@property (nonatomic, strong) CLLocation* myLoc;
@property (nonatomic, assign) CLLocationDistance distance;

@property (nonatomic, assign) NSInteger isReady;
@property (nonatomic, strong) NSMutableArray* tasks;
@end

@implementation PrivatBankAPI

- (instancetype)init {
    self = [super init];
    if (self) {
        self.networkManager = [[AFHTTPSessionManager alloc] init];
        self.networkManager.completionQueue = dispatch_queue_create("com.Exchange.PrivatBankApi.completionQueue", DISPATCH_QUEUE_CONCURRENT);
        self.googleAPIManager = [GoogleAPIManager sharedManager];
        self.tasks = [NSMutableArray array];
    }
    return self;
}

- (void)setIsReady:(NSInteger)isReady {
    _isReady = isReady;
    if (_isReady == 3) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }
}

- (void)cleanAllResource {
    if (self.tasks) {
        [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        [self.tasks removeAllObjects];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}

#pragma mark - Manager Methods

- (void)getAllBankPlaceInCity:(NSString*)city
                        myLoc:(CLLocation*)myLoc
                     inRadius:(CLLocationDistance)distance {
    
    _myLoc = myLoc;
    _distance = distance;
    
    NSString *cityString = city ? city : @"";
    cityString = [cityString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString* getTSO = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/infrastructure?json&tso&city=%@", cityString];
    NSString* getATM = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/infrastructure?json&atm&city=%@", cityString];
    NSString* pboffice = [NSString stringWithFormat:@"https://api.privatbank.ua/p24api/pboffice?json&city=%@",  cityString];
    
    NSURLSessionTask* taskOffice = [self.networkManager GET:pboffice parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            [self parseOffice:responseObject];
            self.isReady += 1;
        }
    } failure:nil];
    
    NSURLSessionTask* taskTSO = [self.networkManager GET:getTSO parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if (responseObject) {
             [self parseBankomat:responseObject];
             self.isReady += 1;
         }
     } failure:nil];
    
    NSURLSessionTask* taskATM = [self.networkManager GET:getATM parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         if (responseObject) {
             [self parseBankomat:responseObject];
             self.isReady += 1;
         }
     } failure:nil];

    [self.tasks addObject:taskOffice];
    [self.tasks addObject:taskTSO];
    [self.tasks addObject:taskATM];
}

#pragma mark - Help methods

- (void)parseBankomat:(id)parseData {
    
    if(![self checkIf:parseData isClass:[NSDictionary class]])
    {return;}
    
    NSArray* arrayOfPlace = [parseData objectForKey:@"devices"];
    if(![self checkIf:arrayOfPlace isClass:[NSArray class]])
    {return;}

    for (NSDictionary* dict in arrayOfPlace) {
        if(![self checkIf:dict isClass:[NSDictionary class]])
        {return;}
        
        NSString* latitude = [dict objectForKey:@"latitude"];
        NSString* longitude = [dict objectForKey:@"longitude"];
        CLLocation *placeLoc = [[CLLocation alloc]initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        if ([placeLoc distanceFromLocation:_myLoc] > _distance) {
            continue;
        }
        
        NSString* type = [dict objectForKey:@"type"];
        NSString* fullAddressUa = [dict objectForKey:@"fullAddressUa"];
        NSString* fullAddressRu = [dict objectForKey:@"fullAddressRu"];
        NSString* fullAddressEn = [dict objectForKey:@"fullAddressEn"];
        NSString* placeUa = [dict objectForKey:@"placeUa"];
        NSString* placeRu = [dict objectForKey:@"placeRu"];
        
        NSString* address = ![fullAddressUa isEqualToString:@""]?fullAddressUa : ![fullAddressRu isEqualToString:@""]?fullAddressRu : fullAddressEn;
        NSString* placeString = ![placeUa isEqualToString:@""]?placeUa : placeRu;
        
        address = [address stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        placeString = [placeString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        
        NSArray* addressComponents = [address componentsSeparatedByString:@","];
        address = [addressComponents[addressComponents.count-2] stringByAppendingFormat:@", %@",addressComponents[addressComponents.count-1]];
        
        BankPlace* place = [[BankPlace alloc]init];
        place.type = type;
        place.fullAddressUa = address;
        place.placeUa = placeString;
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    
        dispatch_async(dispatch_get_main_queue(), ^{
            place.coordinate = coord;
            [self.delegate takeBankPlace:place];
        });
    }
}

- (void)parseOffice:(NSArray*)parseData {
    
    if(![self checkIf:parseData isClass:[NSArray class]])
    {return;}
    
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
        
        __weak PrivatBankAPI* selfWeak = self;
        [self.googleAPIManager getGeocoding:fullAddressUa completionHandler:^(CLLocation *location) {
            if ([location distanceFromLocation:_myLoc] > _distance) {
                return;
            }
            
            BankPlace* place = [[BankPlace alloc]init];
            place.type = type;
            place.fullAddressUa = address;
            place.placeUa = [placeUa stringByReplacingOccurrencesOfString:@"\\" withString:@""];;
            dispatch_async(dispatch_get_main_queue(), ^{
                place.coordinate = location.coordinate;
                [selfWeak.delegate takeBankPlace:place];
            });
        }];
    }
}


- (BOOL)checkIf:(id)obj isClass:(Class)class {
    if (![obj isKindOfClass:class]) {
        return NO;
    }
    return YES;
}

@end
