//
//  SettingsTableViewController.m
//  TipIt
//
//  Created by Juan Pablo Marzetti on 9/29/15.
//  Copyright © 2015 Juan Pablo Marzetti. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *regularServiceField;
@property (weak, nonatomic) IBOutlet UITextField *greatServiceField;
@property (weak, nonatomic) IBOutlet UITextField *goodServiceField;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadSettings];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self storeSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)formatPercentage:(int)percentage {
    return [NSString stringWithFormat:@"%d %%", percentage];
}

- (int)parsePercentage: (NSString *)percentage {
    return [percentage intValue];
}

- (void)loadSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    self.regularServiceField.text = [self formatPercentage:[settings integerForKey:@"regularServiceTip"]];
    self.goodServiceField.text = [self formatPercentage:[settings integerForKey:@"goodServiceTip"]];
    self.greatServiceField.text = [self formatPercentage:[settings integerForKey:@"greatServiceTip"]];
}

- (void)storeSettings {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [settings setInteger:[self parsePercentage:self.regularServiceField.text] forKey:@"regularServiceTip"];
    [settings setInteger:[self parsePercentage:self.goodServiceField.text] forKey:@"goodServiceTip"];
    [settings setInteger:[self parsePercentage:self.greatServiceField.text] forKey:@"greatServiceTip"];
    [settings synchronize];
}
@end
