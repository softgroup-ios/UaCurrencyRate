//
//  CurrencyConvertVC.h
//  Exchange
//
//  Created by Max Ostapchuk on 2/22/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "СurrencyModel.h"
#import "MainVC.h"


@interface CurrencyConvertVC : UIViewController

@property(strong,nonatomic) CurrencyModel *eurModel;
@property(strong,nonatomic) CurrencyModel *rubModel;
@property(strong,nonatomic) CurrencyModel *usdModel;
@property(strong,nonatomic) CurrencyModel *uahModel;

@property (weak, nonatomic) IBOutlet UIPickerView *valuePicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *buyOrSell;

@property (weak, nonatomic) IBOutlet UITextField *summToConvert;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;


- (IBAction)buyOrSellTapped:(id)sender;
- (IBAction)convertButton:(id)sender;
- (IBAction)backButtonAction:(id)sender;


@end
