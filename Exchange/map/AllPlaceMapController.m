//
//  ViewController.m
//  MapGoogles
//
//  Created by admin on 30.11.16.
//  Copyright © 2016 admin. All rights reserved.
//




#import "AllPlaceMapController.h"
#import <MapKit/MapKit.h>
#import "PrivatBankAPI.h"
#import "GoogleAPIManager.h"
#import "BankPlace.h"
#import "constants.h"
#import "MarkerView.h"



@import GoogleMaps;
@import GoogleMapsBase;
@import GoogleMapsCore;


@interface AllPlaceMapController () <CLLocationManagerDelegate, GMSMapViewDelegate, GetAllBankPlaceDelegate>
    
@property (nonatomic,strong) CLLocationManager* locManager;
@property (strong, nonatomic) CLLocation* location;
@property (strong, nonatomic) CLLocation* previusLocation;

@property (strong, nonatomic) NSMutableSet* setOfOffice;
@property (strong, nonatomic) NSMutableSet* setOfATM;
@property (strong, nonatomic) NSMutableSet* setOfTSO;
@property (strong, nonatomic) MarkerView* infoWindowView;

@property (strong, nonatomic) GMSMarker* placeMarker;
@property (strong, nonatomic) GMSPolyline* placePolyline;

@property (nonatomic, strong) PrivatBankAPI* apiManager;
@property (nonatomic, strong) GoogleAPIManager* googleAPIManager;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typePlaceSegmentController;

@property (strong, nonatomic) UIView* backgroundView;
@property (strong, nonatomic) UIImage* atmIcon;
@property (strong, nonatomic) UIImage* terminalIcon;
@property (strong, nonatomic) UIImage* bankIcon;

@end

@implementation AllPlaceMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.backgroundColor = BACKGROUND_MAP_COLOR;
    self.backgroundView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.frame];
    self.backgroundView.backgroundColor = BACKGROUND_MAP_COLOR;
    [self.mapView addSubview:self.backgroundView];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self initLocationManager];
    //[self customizeMap];
    
    self.apiManager = [[PrivatBankAPI alloc] init];
    self.apiManager.delegate = self;
    
    self.googleAPIManager = [GoogleAPIManager sharedManager];
    self.mapView.delegate = self;
    
    [self initInfoWindowView];
}


- (void)customizeMap {
    
    NSURL *styleUrl = [[NSBundle mainBundle] URLForResource:@"style" withExtension:@"json"];
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:nil];
    self.mapView.mapStyle = style;
}

- (void)dealloc {
    [self.mapView clear];
    [self.apiManager cleanAllResource];
    [self.googleAPIManager cleanAllResource];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - init

-(void) initLocationManager {
    self.locManager = [[CLLocationManager alloc]init];
    self.locManager.delegate = self;
    self.locManager.distanceFilter = 100;
    self.locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locManager requestWhenInUseAuthorization];
}

- (void) initInfoWindowView {

    self.infoWindowView =  [[[NSBundle mainBundle] loadNibNamed:@"MarkerView" owner:self options:nil] firstObject];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.infoWindowView.bounds = CGRectMake(0, 0, 250, 70);
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.infoWindowView.bounds = CGRectMake(0, 0, 350, 90);
    }
    self.atmIcon = [UIImage imageNamed:@"atm-icon-256"];
    self.terminalIcon = [UIImage imageNamed:@"terminal-icon-256"];
    self.bankIcon = [UIImage imageNamed:@"bank-icon-256"];
}

#pragma mark - GMSMapViewDelegate

- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView {
    [self.backgroundView setHidden:YES];
}

- (void)mapViewSnapshotReady:(GMSMapView *)mapView {
    
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    [self.infoWindowView.titleLabel setText:marker.title];
    [self.infoWindowView.detailedLabel setText:marker.snippet];
    [self.infoWindowView.imageView setHighlighted:NO];
    self.infoWindowView.distance.text = @"";
    self.infoWindowView.duration.text = @"";
    
    switch ([marker.userData intValue]) {
        case ATM:
            self.infoWindowView.iconImageView.image = self.atmIcon;
            break;
        case TSO:
            self.infoWindowView.iconImageView.image = self.terminalIcon;
            break;
        case OFFICE:
            self.infoWindowView.iconImageView.image = self.bankIcon;
            break;
        default:
            break;
    }
    

    return self.infoWindowView;
}

- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(nonnull GMSMarker *)marker {
    [self searchPathToMarker];
    [self.infoWindowView.imageView setHighlighted:YES];
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
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *location = [locations lastObject];
    self.location = location;
    
    NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;

    if (location.horizontalAccuracy < 0) return;
    
    //if location change more than 1000m
    if (self.previusLocation) {
        if([location distanceFromLocation:self.previusLocation] > 400) {
            [self changeLocation:location];
        }
        else {
            return;
        }
    }
    else {
        [self changeLocation:location];
    }
    
}

#pragma mark - HELP methods

- (void)takeBankPlace:(BankPlace*)place {
    
    switch (place.typeOfEnum) {
        case ATM:
            [self.setOfATM addObject:place];
            break;
        case TSO:
            [self.setOfTSO addObject:place];
            break;
        case OFFICE:
            [self.setOfOffice addObject:place];
            break;
        default:
            break;
    }
    
    if (self.typePlaceSegmentController.selectedSegmentIndex == place.typeOfEnum) {
        place.marker.map = self.mapView;
    }
}

- (void) removeAllPlaces {
    self.setOfATM = [NSMutableSet set];
    self.setOfOffice = [NSMutableSet set];
    self.setOfTSO = [NSMutableSet set];
}

- (void)watchAllMarkersInSet:(NSSet*)markers {
    for (BankPlace* place in markers) {
        place.marker.map = self.mapView;
    }
}

- (void)searchPathToMarker {
    
    __weak AllPlaceMapController* selfWeak = self;
    [self.googleAPIManager getPolylineWithOrigin:self.location.coordinate
                                     destination:self.mapView.selectedMarker.position
                               completionHandler:^(GMSPath* path, NSString* distance, NSString* duration)
     {
         if (!path) {
             return;
         }
         selfWeak.infoWindowView.distance.text = distance;
         selfWeak.infoWindowView.duration.text = duration;
         GMSPolyline* polyline = [GMSPolyline polylineWithPath:path];
         GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
         
         UIEdgeInsets insets = UIEdgeInsetsMake(160, 50, 50, 50);
         GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:insets];
         [selfWeak.mapView animateWithCameraUpdate:update];
         
         selfWeak.placePolyline.map = nil;
         selfWeak.placePolyline = nil;
         
         selfWeak.placePolyline = polyline;
         selfWeak.placePolyline.strokeWidth = 3.f;
         selfWeak.placePolyline.strokeColor = MARKER_COLOR; //BACKGROUND_COLOR;
         selfWeak.placePolyline.map = selfWeak.mapView;
         
     } errorBlock:^(NSError* error) {
         
     }];
}

- (void)changeLocation:(CLLocation*)location {
    
    __block int radius = 6000;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.previusLocation = location;
    self.mapView.myLocationEnabled =  YES;
    
    CGFloat widthPoint = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    CGFloat zoom = [GMSCameraPosition zoomAtCoordinate:location.coordinate forMeters:radius*2 perPoints:widthPoint];
    self.mapView.camera = [[GMSCameraPosition alloc]initWithTarget:location.coordinate zoom:zoom bearing:0 viewingAngle:0];
    
    __weak AllPlaceMapController* selfWeak = self;
    [self.googleAPIManager getReverseGeocoding:location.coordinate completionHandler:^(NSString* cityName){
        if (cityName) {
            radius = 1500;
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat zoom = [GMSCameraPosition zoomAtCoordinate:location.coordinate forMeters:radius*2 perPoints:widthPoint];
                selfWeak.mapView.camera = [[GMSCameraPosition alloc]initWithTarget:location.coordinate zoom:zoom bearing:0 viewingAngle:0];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [selfWeak.mapView clear];
            [selfWeak removeAllPlaces];
        });
        
        [selfWeak.apiManager getAllBankPlaceInCity:cityName myLoc:location inRadius:radius];
    } errorBlock:^(NSError* error) {
        
    }];
}

#pragma mark - Actions

- (IBAction)BackButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeTypePlaces:(UISegmentedControl *)sender {
    [self.mapView clear];
    switch (sender.selectedSegmentIndex) {
        case ATM:
            [self watchAllMarkersInSet:self.setOfATM];
            break;
        case TSO:
            [self watchAllMarkersInSet:self.setOfTSO];
            break;
        case OFFICE:
            [self watchAllMarkersInSet:self.setOfOffice];
            break;
        default:
            break;
    }
}

@end
