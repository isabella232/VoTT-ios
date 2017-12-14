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
               completion:(void (^)(NSDictionary *prediction, NSError *error))completion
{
    UIImage *guitar = [UIImage imageNamed:@"guitar01.jpg"];
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:guitar.CGImage options:@{}];
    NSArray<VNRequest *> *requests = @[[[VNTargetedImageRequest alloc] initWithTargetedImageData:imageData options:@{} completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (VNObservation *observation in request.results) {
                if (observation.confidence > 0.75) {
                    return completion(@{@"Predictions":@[ @{@"Tag":@"electric-guitar", @"Probability":@(observation.confidence)} ]}, error);
                }
            }
            completion(@{}, error);
        });
    }]];
    NSError *error;
    if (![handler performRequests:requests error:&error]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, (error)?error:[NSError errorWithDomain:@"SimulatedImageClassifierErrorDomain" code:1 userInfo:nil]);
        });
        return;
    }
}

@end
