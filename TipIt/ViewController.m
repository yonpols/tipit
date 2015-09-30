//
//  ViewController.m
//  TipIt
//
//  Created by Juan Pablo Marzetti on 9/26/15.
//  Copyright © 2015 Juan Pablo Marzetti. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *billView;
@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *billFieldHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSelector;

@property (weak, nonatomic) IBOutlet UIView *partySizeView;
@property (weak, nonatomic) IBOutlet UILabel *partySizeLabel;
@property (nonatomic) int partySize;
@property (nonatomic) int maxPartySize;
@property (nonatomic) int panStartingPoint;
@property (nonatomic) NSArray *tipPercentages;

@property (weak, nonatomic) IBOutlet UILabel *tipValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalValueLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsBtn;


- (IBAction)billValueChanged:(id)sender;
- (IBAction)tipSelectionChanged:(id)sender;

- (IBAction)handlePartySizeTap:(UIGestureRecognizer *)sender;
- (IBAction)handlePartySizePan:(UIPanGestureRecognizer *)sender;

- (IBAction)handleSettingsTap:(id)sender;


//- (void) updateValues;
//- (IBAction)billEditingDidEnd:(id)sender;
//- (IBAction)tipSelectorChanged:(id)sender;
//- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string;
//
//- (float)billValue;
//

- (float)parseLocaleValue:(NSString *) value;
- (NSString *)formatValue:(float) value;
@end


@implementation ViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.billTextField becomeFirstResponder];
    self.maxPartySize = 6;
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    int regular = 15, good = 20, great = 25;
    
    if (![settings boolForKey:@"initialSettingsSet"]) {
        [settings setInteger:regular forKey:@"regularServiceTip"];
        [settings setInteger:good forKey:@"goodServiceTip"];
        [settings setInteger:great forKey:@"greatServiceTip"];
        [settings setBool:YES forKey:@"initialSettingsSet"];
        [settings setInteger:0 forKey:@"selectedTip"];
        [settings setInteger:1 forKey:@"partySize"];
        [settings setObject:[self formatValue:0.00] forKey:@"billValue"];

        self.tipSelector.selectedSegmentIndex = 0;
        [settings synchronize];
    } else {
        regular = (int)[settings integerForKey:@"regularServiceTip"];
        good = (int)[settings integerForKey:@"goodServiceTip"];
        great = (int)[settings integerForKey:@"greatServiceTip"];
    }
    
    self.tipPercentages = @[@(regular), @(good), @(great)];
    [self.tipSelector setTitle:[NSString stringWithFormat:@"%d %%", regular] forSegmentAtIndex:(NSUInteger)0];
    [self.tipSelector setTitle:[NSString stringWithFormat:@"%d %%", good] forSegmentAtIndex:(NSUInteger)1];
    [self.tipSelector setTitle:[NSString stringWithFormat:@"%d %%", great] forSegmentAtIndex:(NSUInteger)2];

    int timestamp = (int)[settings integerForKey:@"billTimestamp"];
    if (timestamp == 0 || [NSDate timeIntervalSinceReferenceDate] - timestamp > 600) {
        [self hideTipView:NO];
        self.billTextField.text = [self formatValue:0.00];
        self.tipSelector.selectedSegmentIndex = 0;
        self.partySize = 1;
    } else {
        [self showTipView:NO];
        self.billTextField.text = [settings stringForKey:@"billValue"];
        self.tipSelector.selectedSegmentIndex = [settings integerForKey:@"selectedTip"];
        self.partySize = (int)[settings integerForKey:@"partySize"];
    }

    [self updatePartySizeLabel:self.partySize];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSLog(@"%d tip", self.tipSelector.selectedSegmentIndex);
    [settings setInteger:self.tipSelector.selectedSegmentIndex forKey:@"selectedTip"];
    [settings setInteger:self.partySize forKey:@"partySize"];
    [settings setObject:self.billTextField.text forKey:@"billValue"];
    [settings setInteger:[NSDate timeIntervalSinceReferenceDate] forKey:@"billTimestamp"];
    [settings synchronize];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideTipView:(BOOL) animated {
    [UIView animateWithDuration:(animated ? 0.4 : 0) animations:^{
        self.billFieldHeightConstraint.constant = 200;
        self.tipView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)showTipView:(BOOL) animated {
    [UIView animateWithDuration:(animated ? 0.4 : 0) animations:^{
        self.billFieldHeightConstraint.constant = 80;
        self.tipView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void) updatePartySizeLabel:(int)partySize {
    self.partySize = partySize;
    self.partySizeLabel.text = [@"" stringByPaddingToLength:(partySize * 2) withString:@"\uf007 " startingAtIndex:0];
    
    [self updateValues];
}

- (float)parseLocaleValue:(NSString*) value {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSNumber *number = [formatter numberFromString:value];
    return [number floatValue];
}

- (NSString *)formatValue:(float) value {
    return [NSNumberFormatter localizedStringFromNumber:@(value) numberStyle:NSNumberFormatterCurrencyStyle];
}

- (void) updateValues {
    float billValue = [self parseLocaleValue:self.billTextField.text];
    float tipPercentage = [self.tipPercentages[self.tipSelector.selectedSegmentIndex] floatValue] / 100;
    float tip = billValue * tipPercentage;
    float total = billValue + tip;
    float yourTip = tip / self.partySize;
    float yourTotal = total / self.partySize;
    
    self.tipValueLabel.text = [self formatValue:yourTip];
    self.totalValueLabel.text = [self formatValue:yourTotal];
}

- (BOOL)textField:(UITextField * _Nonnull)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString * _Nonnull)string {
    if (textField == self.billTextField) {
        NSInteger centValue = [self parseLocaleValue:textField.text] * 100;
        
        if (string.length > 0) {
            centValue = centValue * 10 + string.integerValue;
        } else {
            centValue = centValue / 10;
        }
        
        if (centValue == 0) {
            [self hideTipView:YES];
        } else {
            [self showTipView:YES];
        }

        textField.text = [self formatValue:((float)centValue / 100.0f)];
        [self updateValues];
        return NO;
    }

    return YES;
}

- (IBAction)handlePartySizeTap:(UIGestureRecognizer *)sender {
    int newPartySize = (self.partySize % self.maxPartySize) + 1;
    [self updatePartySizeLabel:newPartySize];
    [self.view endEditing:YES];
}

- (IBAction)billValueChanged:(id)sender {
    [self updateValues];
}

- (IBAction)tipSelectionChanged:(id)sender {
    [self updateValues];
    [self.view endEditing:YES];
}

- (IBAction)handlePartySizePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.partySizeView];

    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.view endEditing:YES];
        self.panStartingPoint = translation.x;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        int stepSize = self.partySizeView.frame.size.width / (self.maxPartySize * 2);
        int step = (translation.x - self.panStartingPoint) / stepSize;
        int newPartySize = self.partySize + step;
        
        if (step != 0 && newPartySize > 0 && newPartySize <= self.maxPartySize) {
            self.panStartingPoint = translation.x;
            [self updatePartySizeLabel:newPartySize];
        }
    }
}

- (IBAction)handleSettingsTap:(id)sender {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

@end
