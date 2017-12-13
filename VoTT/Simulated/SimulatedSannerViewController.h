//
//  SimulatedSannerViewController.h
//  VoTT
//
//  Created by JC Jimenez on 12/12/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SimulatedSannerViewControllerCompletion)(NSURL *projectURL, NSError *error);

@interface SimulatedSannerViewController : UIViewController

@property (nonatomic, strong) SimulatedSannerViewControllerCompletion scanCompletion;

@end
