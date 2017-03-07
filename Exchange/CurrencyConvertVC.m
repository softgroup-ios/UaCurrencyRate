//
//  CurrencyConvertVC.m
//  Exchange
//
//  Created by Max Ostapchuk on 2/22/17.
//  Copyright © 2017 Max Ostapchuk. All rights reserved.
//

#import "CurrencyConvertVC.h"
#import "constants.h"

@interface CurrencyConvertVC () <UIPickerViewDataSource, UIPickerViewDelegate , UITextFieldDelegate, UIViewControllerTransitioningDelegate>

@property(strong,nonatomic) NSArray *pickerData;
@property(assign,nonatomic) NSInteger selectedPickerFirstComponent;
@property(assign,nonatomic) NSInteger selectedPickerSecondComponent;
@property(assign,nonatomic) float pickerRect;
@property(nonatomic, assign) BOOL buyVariant;

@end

@implementation CurrencyConvertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_summToConvert addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    UIFont *font = [UIFont boldSystemFontOfSize:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [_buyOrSell setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    self.uahModel.buyRate = 1.0f;
    self.uahModel.sellRate = 1.0f;
    self.pickerData = @[@"USD",@"EUR",@"UAH",@"RUB"];
    self.valuePicker.dataSource = self;
    self.valuePicker.delegate = self;
    self.summToConvert.delegate = self;
    
    _showPickerBtn.layer.cornerRadius = 4;
    _showPickerBtn.clipsToBounds = YES;
    self.buyVariant = YES;
    [self addGestureRecognizers];
    [self customKeyBoard];
    [self addLongPress];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.backGroundImage.image = [UIImage imageNamed:@"internet"];
    self.summToConvert.text = @"";
    self.resultTextField.text = @"";
    self.valuePicker.hidden = YES;
    [_summToConvert resignFirstResponder];
}


#pragma mark - Picker Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{

    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    return self.pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    return self.pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
            self.fromCurrencyLabel.text = self.pickerData[row];
            self.selectedPickerFirstComponent = row;
            [self textFieldDidChange:_resultTextField];
            break;
        case 1:
            self.toCurrencyLabel.text = self.pickerData[row];
            self.selectedPickerSecondComponent = row;
            [self textFieldDidChange:_resultTextField];
        default:
            break;
    }
    
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSAttributedString *styledString = [[NSAttributedString alloc] initWithString:self.pickerData[row] attributes:@{NSForegroundColorAttributeName:WHITE_COLOR}];
    return styledString;
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

-(void)swapValues{
    
    NSInteger tmp = self.selectedPickerFirstComponent;
    [self.valuePicker selectRow:self.selectedPickerSecondComponent inComponent:0 animated:NO];
    [self.valuePicker selectRow:tmp inComponent:1 animated:NO];
    NSString *tmpStr = self.fromCurrencyLabel.text;
    self.fromCurrencyLabel.text = self.toCurrencyLabel.text;
    self.toCurrencyLabel.text = tmpStr;
    [self textFieldDidChange:_resultTextField];
}

#pragma mark - Calculate result of converting

-(float)createResultWith:(float)firstModel and:(float)secondModel{
    
    NSNumber *number = [[NSNumberFormatter new] numberFromString: _summToConvert.text];
    float inputNum = number.floatValue;
    float resultNum;
    CurrencyModel *firstPickerModel = [self getPickerValue:_selectedPickerFirstComponent];
    CurrencyModel *secondPickerModel = [self getPickerValue:_selectedPickerSecondComponent];
    
    if(firstPickerModel == _uahModel){
            resultNum = (inputNum / secondModel);
    }else
        if(secondPickerModel == _uahModel){
            resultNum = (inputNum * firstModel);
        }else
            resultNum = (inputNum / secondModel)*firstModel;
    return resultNum;
}

#pragma mark - Buttons

- (IBAction)showPickerButton:(id)sender {

    _valuePicker.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.valuePicker.alpha = 1.f;
        _fromLabel.alpha = 1.f;
        _toLabel.alpha = 1.f;
        self.equalsArrow.alpha = 0.f;
        _fromCurrencyLabel.alpha = 0.f;
        _toCurrencyLabel.alpha = 0.f;
    }];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer{
    [self doneWithNumberPad];
    [UIView animateWithDuration:0.4 animations:^{
        self.valuePicker.alpha = 0.f;
        _fromLabel.alpha = 0.f;
        _toLabel.alpha = 0.f;
        self.equalsArrow.alpha = 1.f;
        _fromCurrencyLabel.alpha = 1.f;
        _toCurrencyLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
        _valuePicker.hidden = YES;
    }];
}

- (IBAction)buyOrSellTapped:(id)sender {
    
    if(self.buyOrSell.selectedSegmentIndex == 0){
        self.buyVariant = NO;
        [self textFieldDidChange:_resultTextField];
    }
    else {
        self.buyVariant = YES;
        [self textFieldDidChange:_resultTextField];
    }
}

- (IBAction)backButtonAction:(id)sender {
    
    [_summToConvert resignFirstResponder];
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) {
        return YES;
    }
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSRange searchRange =  [string rangeOfCharacterFromSet:myCharSet];
    if(searchRange.location != NSNotFound) {
        return YES;
    }
    
    UIAlertController *alert = [UIAlertController
                                  alertControllerWithTitle:@"Invalid Input"
                                  message:@"Only numbers are allowed."
                                  preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Continue"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                            
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    return NO;
}

-(void)textFieldDidChange :(UITextField *)theTextField{
    
    float result;
    CurrencyModel *firstPickerModel = [self getPickerValue:_selectedPickerFirstComponent];
    CurrencyModel *secondPickerModel = [self getPickerValue:_selectedPickerSecondComponent];
    
    if(self.buyVariant){
        result = [self createResultWith:firstPickerModel.buyRate and:secondPickerModel.buyRate];
    }else{
        result = [self createResultWith:firstPickerModel.sellRate and:secondPickerModel.sellRate];
    }
    self.resultTextField.text = [NSString stringWithFormat:@"%.2f",result];
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

#pragma mark - Swipe Recognizer

-(void)addGestureRecognizers{
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(swipeSegue)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    UITapGestureRecognizer *swipeValues = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(swapValues)];
    swipeValues.numberOfTapsRequired = 1;
    [self.equalsArrow setUserInteractionEnabled:YES];
    [self.equalsArrow addGestureRecognizer:swipeValues];
}

-(void)swipeSegue{
    
    [_summToConvert resignFirstResponder];
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Pashalki

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if(UIGestureRecognizerStateBegan == gesture.state) {
        _backGroundImage.image = [UIImage imageNamed:@"trump"];
    }
}

-(void)addLongPress{
    _longPress = [[UILongPressGestureRecognizer alloc]
                  initWithTarget:self
                  action:@selector(handleLongPress:)];
    _longPress.minimumPressDuration = 2.0;
    [self.view addGestureRecognizer:_longPress];
}

@end
