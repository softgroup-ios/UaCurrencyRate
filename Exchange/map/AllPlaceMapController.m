//
//  ViewController.m
//  MapGoogles
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//




#import "AllPlaceMapController.h"
#import <MapKit/MapKit.h>
#import "PrivatBankApiManager.h"
#import "GoogleAPIManager.h"
#import "BankPlace.h"
#import "InfoWindowView.h"



@import GoogleMaps;
@import GoogleMapsBase;
@import GoogleMapsCore;


@interface AllPlaceMapController () <CLLocationManagerDelegate, GMSMapViewDelegate>
    
@property (nonatomic,strong) CLLocationManager* locManager;
@property (strong, nonatomic) CLLocation* previusLocation;

@property (strong, nonatomic) NSSet* setOfOffice;
@property (strong, nonatomic) NSSet* setOfATM;
@property (strong, nonatomic) NSSet* setOfTSO;
@property (strong, nonatomic) InfoWindowView* infoWindowView;

@property (strong, nonatomic) GMSMarker* placeMarker;
@property (strong, nonatomic) GMSPolyline* placePolyline;

@property (nonatomic, strong) PrivatBankApiManager* apiManager;
@property (nonatomic, strong) GoogleAPIManager* googleAPIManager;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typePlaceSegmentController;

@end

@implementation AllPlaceMapController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLocationManager];
    self.apiManager = [PrivatBankApiManager sharedManager];
    self.googleAPIManager = [GoogleAPIManager sharedManager];
    
    self.mapView.delegate = self;
    
    [self initInfoWindowView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self.mapView clear];
}

#pragma mark - init
-(void) initLocationManager
{
    self.locManager = [[CLLocationManager alloc]init];
    self.locManager.delegate = self;
    self.locManager.distanceFilter = 1;
    self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locManager requestWhenInUseAuthorization];
}

- (void) initInfoWindowView
{
    self.infoWindowView = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindowView" owner:self options:nil] firstObject];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.infoWindowView.bounds = CGRectMake(0, 0, 250, 70);
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.infoWindowView.bounds = CGRectMake(0, 0, 450, 80);
    }
}

#pragma mark - GMSMapViewDelegate

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    self.infoWindowView.titleLabel.text = marker.title;
    self.infoWindowView.detailedLabel.text = marker.snippet;
    
    return self.infoWindowView;
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if  ((status == kCLAuthorizationStatusAuthorizedWhenInUse) ||
        (status == kCLAuthorizationStatusAuthorizedAlways))
    {
        [self.locManager startUpdatingLocation];
        self.mapView.myLocationEnabled = YES;
        self.mapView.settings.myLocationButton = YES;
    }
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];

    //if
    static NSDate *previousLocationTimestamp;
    if (previousLocationTimestamp && [location.timestamp timeIntervalSinceDate:previousLocationTimestamp] < 2.0)
    {
        return;
    }
    previousLocationTimestamp = location.timestamp;
    
    
    //if current loc change
    void(^ChangeSelfLocation)(CLLocation*)  = ^(CLLocation* location)
    {
        self.previusLocation = location;
        self.mapView.myLocationEnabled =  YES;
        self.mapView.camera = [[GMSCameraPosition alloc]initWithTarget:location.coordinate zoom:13 bearing:0 viewingAngle:0];
        
        
        [self.googleAPIManager getReverseGeocoding:location.coordinate completionHandler:^(NSDictionary* dict)
        {
            NSString* city = [dict objectForKey:@"city"];
            NSString* addressString = [dict objectForKey:@"country"];
            
            addressString = [[addressString componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet] ] firstObject];
            
            if (city)
            {
                addressString = nil;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView clear];
            });
            
            [self.apiManager getAllBankPlaceInCity:city orAddress:addressString WithComplateBlock:^(NSSet* set)
             {
                 switch (((BankPlace*)[set anyObject]).typeOfEnum)
                 {
                     case ATM:
                         self.setOfATM = set;
                         break;
                     case TSO:
                         self.setOfTSO = set;
                         break;
                     case OFFICE:
                         self.setOfOffice = set;
                         break;
                     default:
                         break;
                 }
                 
                 switch (self.typePlaceSegmentController.selectedSegmentIndex)
                 {
                     case ATM:
                         [self watchAllMarkersInSet:self.setOfATM inRadius:10000.f];
                         break;
                     case TSO:
                         [self watchAllMarkersInSet:self.setOfTSO inRadius:10000.f];
                         break;
                     case OFFICE:
                         [self watchAllMarkersInSet:self.setOfOffice inRadius:10000.f];
                     default:
                         break;
                 }
             }
             errorBlock:^(NSError* error)
             {
                 
             }];

        } errorBlock:^(NSError* error) {
            
        }];
    };
    
    //if location change more than 1000m
    if (self.previusLocation)
    {
        if([location distanceFromLocation:self.previusLocation] > 1000)
        {
            if (location)
            {
                ChangeSelfLocation(location);
            }
        }
        else
        {
            return;
        }
    }
    else if (location)
    {
        ChangeSelfLocation(location);
    }
    
}

- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(nonnull GMSMarker *)marker
{
    [self.googleAPIManager getPolylineWithOrigin:self.previusLocation.coordinate
                                     destination:self.mapView.selectedMarker.position
                               completionHandler:^(GMSPath* path)
     {
         GMSPolyline* polyline = [GMSPolyline polylineWithPath:path];
         
         GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
         GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
         [self.mapView moveCamera:update];
         
         self.placePolyline.map = nil;
         self.placePolyline = nil;
         
         self.placePolyline = polyline;
         self.placePolyline.strokeWidth = 2.f;
         self.placePolyline.map = self.mapView;
         
     } errorBlock:^(NSError* error)
     {
         
     }];
    
}

#pragma mark - HELP methods

- (void) removeAllPlaces
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.setOfATM)
        {
            for (BankPlace* place in self.setOfATM)
            {
                place.marker.map = nil;
            }
            self.setOfATM = nil;
        }
        
        if (self.setOfOffice)
        {
            for (BankPlace* place in self.setOfOffice)
            {
                place.marker.map = nil;
            }
            self.setOfOffice = nil;
        }
        
        if (self.setOfTSO)
        {
            for (BankPlace* place in self.setOfTSO)
            {
                place.marker.map = nil;
            }
            self.setOfTSO = nil;
        }
    });
}

- (void) watchAllMarkersInSet: (NSSet*) markers inRadius: (CLLocationDistance) radius
{
    for (BankPlace* place in markers)
    {
        CLLocation* loc = [[CLLocation alloc]initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
        
        if ([loc distanceFromLocation:self.previusLocation] < radius)
        {
            place.marker.map = self.mapView;
        }
    }
}

#pragma mark - Actions

- (IBAction)BackButton:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeTypePlaces:(UISegmentedControl *)sender
{
    [self.mapView clear];
    switch (sender.selectedSegmentIndex)
    {
        case ATM:
            [self watchAllMarkersInSet:self.setOfATM inRadius:10000.f];
            break;
        case TSO:
            [self watchAllMarkersInSet:self.setOfTSO inRadius:10000.f];
            break;
        case OFFICE:
            [self watchAllMarkersInSet:self.setOfOffice inRadius:10000.f];
            break;
        default:
            break;
    }
}
@end
