//
//  SimulatedImageTagService.m
//  Image Tag
//
//  Created by JC Jimenez on 11/17/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "SimulatedImageTagService.h"
#import "SimulatedImageTagSession.h"
#import <UIKit/UIKit.h>

@implementation SimulatedImageTagService

- (void)startSession:(NSURL *)url
          completion:(void (^)(id <MSImageTagSession> session, NSError *error))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion([[SimulatedImageTagSession alloc] init], nil);
    });
}

@end

