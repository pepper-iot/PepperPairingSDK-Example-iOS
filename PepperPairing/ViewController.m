//
//  ViewController.m
//  PepperPairing
//
//  Created by lukecurran on 06/07/2021.
//  Copyright (c) 2021 lukecurran. All rights reserved.
//

#import <PepperPairing/SoftAPManager.h>
#import "ViewController.h"
#import "WifiViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *hostTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *shiftCipherTextField;
@property (weak, nonatomic) IBOutlet UITextField *ssidPrefixTextField;

@end

@implementation ViewController

- (IBAction)connectToDevice:(id)sender {
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    UInt16 portNumber = [[formatter numberFromString:self.portTextField.text] unsignedShortValue];
    int shiftCipher = [[formatter numberFromString:self.shiftCipherTextField.text] unsignedIntValue];

    // Initialize the SoftAPManager
    [[SoftAPManager sharedManager] initialize:self.hostTextField.text port:portNumber shiftCipher:shiftCipher timeout:30 encodingType:NSUTF8StringEncoding completion:^(BOOL connected) {
        // Must access ui on the main thread
        // TODO: Research executing the completion block on the main queue
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (connected) {
                NSLog(@"Connected!");
                WifiViewController *wifiVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WifiViewController"];
                [self.navigationController pushViewController:wifiVc animated:true];
            } else {
                NSString* alertMsg = [NSString stringWithFormat:@"Failed to connect to Host = %@, Port = %d, Shift Cipher = %@", self.hostTextField.text, portNumber, self.shiftCipherTextField.text];
                NSLog(@"%@", alertMsg);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connect" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                   handler:^(UIAlertAction * action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:true completion:nil];
            }
        });
    }];
}

- (IBAction)autoJoinHotspot:(id)sender {
    NSString* prefix = self.ssidPrefixTextField.text;
    if (!prefix || [prefix length] == 0) {
        NSLog(@"Validation: Must provide valid prefix");
        return;
    }
    [[SoftAPManager sharedManager] autoJoinHotspotWithPrefix:prefix completion:^(NSString* connectedPrefix) {
        // TODO: Figure out if we should provide an error
        dispatch_async(dispatch_get_main_queue(), ^() {
            NSString* alertMsg;
            if (connectedPrefix) {
                NSLog(@"Auto join device hotspot with prefix: %@", connectedPrefix);
                alertMsg = @"Joined! Now hit 'Connect to Device' to start the SoftAP flow.";
            } else {
                NSLog(@"Failed to join hotspot with prefix: %@", prefix);
                alertMsg = [NSString stringWithFormat:@"Failed to join hotspot with prefix: %@", prefix];
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Auto-Join" message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
               handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:true completion:nil];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.hostTextField.text = @"192.168.8.1";
    self.hostTextField.delegate = self;

    self.portTextField.text = @"5053";
    self.portTextField.delegate = self;
    
    self.shiftCipherTextField.text = @"4";
    self.shiftCipherTextField.delegate = self;
    
    self.ssidPrefixTextField.text = @"PEC";
    self.ssidPrefixTextField.delegate = self;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
