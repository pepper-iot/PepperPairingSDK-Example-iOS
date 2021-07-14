//
//  WifiViewController.m
//  PepperPairing_Example
//
//  Created by lukecurran on 06/11/2021.
//  Copyright (c) 2021 lukecurran. All rights reserved.
//

#import <PepperPairing/SoftAPManager.h>
#import "WifiViewController.h"
#import "WifiCredentialsViewController.h"

@interface WifiViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *wifiTableView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation WifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Initialized: %hhd", [SoftAPManager.sharedManager isInitialized]);
    wifiList = [[NSArray alloc] init];
    self.wifiTableView.dataSource = self;
    self.wifiTableView.delegate = self;

    // Get Wi-fi list
    [self.activityIndicator startAnimating];
    [SoftAPManager.sharedManager getWifiList:^(NSError* err, NSArray* ssids) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.activityIndicator stopAnimating];
            if (err) {
                NSLog(@"Error getting wifi list: %@", err.localizedDescription);
                return;
            }
            NSLog(@"WIFI results retrieved: %@", ssids);
            wifiList = ssids;
            [self.wifiTableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [wifiList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wifiItem"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wifiItem"];
    }
    cell.textLabel.text = [wifiList objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    WifiCredentialsViewController *wifiCredsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"WifiCredentialsViewController"];
    wifiCredsVc.ssid = [wifiList objectAtIndex:indexPath.row];
    NSMutableDictionary* wifiInfo = [SoftAPManager.sharedManager getWifiInfo:[wifiList objectAtIndex:indexPath.row]];
    NSLog(@"Info for chosen SSID: %@", wifiInfo);
    [self.navigationController pushViewController:wifiCredsVc animated:true];
}

@end
