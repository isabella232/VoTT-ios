//
//  SimulatedImageClassificationService.m
//  VoTT
//
//  Created by JC Jimenez on 12/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "SimulatedImageClassifier.h"
#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

@implementation SimulatedImageClassifier

- (void)classifyImageData:(NSData *)imageData
               completion:(void (^)(NSString *classNamePrediction, NSError *error))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion(self.objectClass, nil);
    });
}

@end
