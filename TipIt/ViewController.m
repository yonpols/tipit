//
//  ViewController.m
//  TipIt
//
//  Created by Juan Pablo Marzetti on 9/26/15.
//  Copyright © 2015 Juan Pablo Marzetti. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UILabel *partySizeLabel;
@property (weak, nonatomic) IBOutlet UISlider *partySizeSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tipSegementedControl;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (nonatomic) int partySize;

- (IBAction)partySizeChanged:(id)sender;
- (void) updateValues;
- (IBAction)billEditingDidEnd:(id)sender;
- (IBAction)tipSelectorChanged:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.partySize = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)partySizeChanged:(id)sender {
    self.partySizeSlider.value = floor(self.partySizeSlider.value);
    
    if (self.partySize != self.partySizeSlider.value) {
        [self.view endEditing:YES];
        self.partySizeLabel.text = [NSString stringWithFormat:@"%0.0f part%@", self.partySizeSlider.value, (self.partySizeSlider.value == 1 ? @"y": @"ies")];
        [self updateValues];
        self.partySize = self.partySizeSlider.value;
    }
}

- (void) updateValues {
    NSArray *tipPercentages = @[@(0.1), @(0.15), @(0.2)];
    
    float billValue = [self.billTextField.text floatValue];
    float tipPercentage = [tipPercentages[self.tipSegementedControl.selectedSegmentIndex] floatValue];
    float tip = billValue * tipPercentage;
    float total = billValue + tip;
    float yourTip = tip / self.partySizeSlider.value;
    float yourTotal = total / self.partySizeSlider.value;
    
    self.totalLabel.text = [NSString stringWithFormat:@"$ %0.2f", yourTotal];
}

- (IBAction)billEditingDidEnd:(id)sender {
    [self updateValues];
}

- (IBAction)tipSelectorChanged:(id)sender {
    [self.view endEditing:YES];
    [self updateValues];
}
@end
