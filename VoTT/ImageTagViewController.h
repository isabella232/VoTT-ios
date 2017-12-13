//
//  ImageTagViewController.h
//  VoTT
//
//  Created by JC Jimenez on 12/12/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSImageTagSession;

@interface ImageTagViewController : UIViewController

@property (nonatomic, strong) NSObject<MSImageTagSession> *session;

@end
