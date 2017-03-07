//
//  ViewController.h
//  Exchange
//
//  Created by Max Ostapchuk on 2/21/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *rubBuy;
@property (weak, nonatomic) IBOutlet UILabel *rubSell;
@property (weak, nonatomic) IBOutlet UILabel *usdBuy;
@property (weak, nonatomic) IBOutlet UILabel *usdSell;
@property (weak, nonatomic) IBOutlet UILabel *eurBuy;
@property (weak, nonatomic) IBOutlet UILabel *eurSell;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateLabel;

@property (weak, nonatomic) IBOutlet UIImageView *eurCompraisonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rubComprasionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *usdComprasionImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;

- (IBAction)refreshButtonAction:(id)sender;
- (IBAction)moneyConvertButton:(id)sender;

@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *rateActivityIndicators;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *topLongPress;

@end

