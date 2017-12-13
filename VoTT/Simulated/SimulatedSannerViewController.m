//
//  SimulatedSannerViewController.m
//  VoTT
//
//  Created by JC Jimenez on 12/12/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "SimulatedSannerViewController.h"

@interface SimulatedSannerViewController ()

@end

@implementation SimulatedSannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_scanCompletion) {
            _scanCompletion([NSURL URLWithString:@"https://www.microsoft.com/developerblog/"], nil);
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
