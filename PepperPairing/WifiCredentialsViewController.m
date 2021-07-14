//
//  WifiCredentialsViewController.m
//  PepperPairing_Example
//
//  Created by Luke Curran on 6/11/21.
//  Copyright © 2021 lukecurran. All rights reserved.
//

#import <PepperPairing/SoftAPManager.h>
#import "WifiCredentialsViewController.h"

@interface WifiCredentialsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ssidTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverUrlTextField;

@property (weak, nonatomic) IBOutlet UIButton *softAPButton;

@end

@implementation WifiCredentialsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (self.ssid) {
        self.ssidTextField.text = self.ssid;
        [self.passwordTextField becomeFirstResponder];
    } else {
        [self.ssidTextField becomeFirstResponder];
    }
    
    // Set defaults
    self.accountIdTextField.text = @"2283e32b-3092-42e7-bb5d-79037b598e38"; // Luke's dev account
    self.serverUrlTextField.text = @"wss://dev.move.pepperos.io/ws";
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startSoftAP:(id)sender {
    if (!self.ssidTextField.text || !self.passwordTextField.text) {
        NSLog(@"Must provide SSID and Password to SoftAPManager");
        return;
    }
    self.softAPButton.enabled = NO;
    SoftAPStartParams *softApParams = [[SoftAPStartParams alloc] initWithSSID:self.ssidTextField.text password:self.passwordTextField.text accountId:self.accountIdTextField.text serverUrl:self.serverUrlTextField.text];
    [SoftAPManager.sharedManager performSoftAP:softApParams completion:^(NSError* err, SoftAPExecutionResponse* response) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            NSString *alertMsg;
            if (err) {
                NSLog(@"Failed to execute SoftAP: %@", err.localizedDescription);
                self.softAPButton.enabled = YES;
                alertMsg = [NSString stringWithFormat:@"Failed to execute SoftAP: %@", err.localizedDescription];
            } else {
                NSLog(@"Boom! SoftAP completed");
                alertMsg = @"SoftAP completed successfully. Device is pairing...";
                NSLog(@"DeviceId: %@, Provider: %@", response.deviceId, response.provider);
            }
        
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SoftAP" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:true completion:nil];
        });
    }];
}

@end
