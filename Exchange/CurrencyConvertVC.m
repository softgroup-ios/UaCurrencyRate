//
//  CurrencyConvertVC.m
//  Exchange
//
//  Created by Max Ostapchuk on 2/22/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import "CurrencyConvertVC.h"
#import "constants.h"

@interface CurrencyConvertVC () <UIPickerViewDataSource, UIPickerViewDelegate , UITextFieldDelegate>

@property(strong,nonatomic) NSArray *pickerData;
@property(nonatomic, assign) BOOL buyVariant;
@property(assign,nonatomic) NSInteger selectedPickerFirstComponent;
@property(assign,nonatomic) NSInteger selectedPickerSecondComponent;

@end

@implementation CurrencyConvertVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self customKeyBoard];
    self.summToConvert.delegate = self;
    self.uahModel.buyRate = 1.0f;
    self.uahModel.sellRate = 1.0f;
    self.pickerData = @[@"USD",@"EUR",@"UAH",@"RUB"];
    self.valuePicker.dataSource = self;
    self.valuePicker.delegate = self;
}


#pragma mark - Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerData.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            self.selectedPickerFirstComponent = row;
            break;
        case 1:
            self.selectedPickerSecondComponent = row;
        default:
            break;
    }
    
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.pickerData[row] attributes:@{NSForegroundColorAttributeName:WHITE_COLOR}];
    return attString;
}

- (CurrencyModel*)getPickerValue:(NSInteger)numberOfSelection{
    
    if(numberOfSelection == 0){
        return _usdModel;
    }else
        if(numberOfSelection == 1){
            return _eurModel;
        }else
            if(numberOfSelection == 2){
                return _uahModel;
            }else
                return _rubModel;
}



#pragma mark - Calculate result of converting

-(float)createResultWith:(float)firstModel and:(float)secondModel{
    
    float inputNum = [_summToConvert.text floatValue];
    float resultNum;
    
    if([self getPickerValue:_selectedPickerFirstComponent] == _uahModel){
        resultNum = (inputNum / secondModel);
    }else
        if([self getPickerValue:_selectedPickerSecondComponent] == _uahModel){
            resultNum = (inputNum * firstModel);
        }else
            if([[self getPickerValue:_selectedPickerFirstComponent] isEqual:_uahModel] && [[self getPickerValue:_selectedPickerSecondComponent] isEqual:_uahModel]){
                resultNum = inputNum;
            }else
            resultNum = (inputNum / secondModel)*firstModel;
    return resultNum;
}

#pragma mark - Buttons

- (IBAction)convertButton:(id)sender {
    float result;
    if(self.buyVariant){
        result = [self createResultWith:[self getPickerValue:self.selectedPickerFirstComponent].buyRate and:[self getPickerValue:self.selectedPickerSecondComponent].buyRate];
    }else{
        result = [self createResultWith:[self getPickerValue:self.selectedPickerFirstComponent].sellRate and:[self getPickerValue:self.selectedPickerSecondComponent].sellRate];
    }
    self.resultLabel.text = [NSString stringWithFormat:@"%.2f",result];
}

- (IBAction)buyOrSellTapped:(id)sender {
    
    if(self.buyOrSell.selectedSegmentIndex==0){
        
        self.buyVariant = NO;
    }
    else {
        
        self.buyVariant = YES;
    }
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) {
        return YES;
    }
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            return YES;
        }
    }
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Invalid Input" message:@"Only numbers are allowed for participant number." delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [av show];
    return NO;
}

#pragma mark - Keyboard

-(void)customKeyBoard{
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)];
    doneButton.tintColor = WHITE_COLOR;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],doneButton];
    [numberToolbar sizeToFit];
    _summToConvert.inputAccessoryView = numberToolbar;
}

-(void)doneWithNumberPad{
    [_summToConvert resignFirstResponder];
}



@end
