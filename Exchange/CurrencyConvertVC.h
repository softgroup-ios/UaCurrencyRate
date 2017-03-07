//
//  CurrencyConvertVC.h
//  Exchange
//
//  Created by Max Ostapchuk on 2/22/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZTransitions.h"
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
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;

- (IBAction)showPickerButton:(id)sender;
- (IBAction)buyOrSellTapped:(id)sender;
- (IBAction)backButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *toCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromCurrencyLabel;

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIButton *showPickerBtn;

- (void)handleLongPress:(UILongPressGestureRecognizer*)sender;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPress;

@property (weak, nonatomic) IBOutlet UIImageView *equalsArrow;

@end
