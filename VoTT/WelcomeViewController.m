//
//  WelcomeViewController.m
//  VoTT
//
//  Created by JC Jimenez on 12/6/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SimulatedSannerViewController.h"
#import "SimulatedImageTagService.h"
#import "MBProgressHUD.h"

@interface WelcomeViewController ()

@property (nonatomic, strong) id<MSImageTagSession> session;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)scan:(id)sender {
    NSLog(@"%s", __FUNCTION__);
#if TARGET_OS_SIMULATOR
    NSLog(@"Simulated scan.");
    __block WelcomeViewController *blockSelf = self;
    SimulatedSannerViewController *scanner = [[SimulatedSannerViewController alloc] init];
    scanner.modalPresentationStyle = UIModalPresentationFullScreen;
    [scanner setScanCompletion:^(NSURL *projectURL, NSError *error) {
        [blockSelf dismissViewControllerAnimated:YES completion:^{
            SimulatedImageTagService *service = [[SimulatedImageTagService alloc] init];
            MBProgressHUD *saveHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            saveHUD.label.text = @"Loading Project...";
            [service startSession:projectURL completion:^(id<MSImageTagSession> session, NSError *error) {
                [saveHUD hideAnimated:YES];
                
                blockSelf.session = session;
                [self performSegueWithIdentifier:@"start" sender:self];
            }];
        }];
    }];
    [self presentViewController:scanner animated:YES completion:nil];
#else
    NSLog(@"TODO: Kick off QR code scan.");
#endif
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    [segue.destinationViewController setValue:self.session forKey:@"session"];
}

@end
