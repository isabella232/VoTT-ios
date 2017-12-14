//
//  SimulatedImageTagSession.m
//  VoTT
//
//  Created by JC Jimenez on 12/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "SimulatedImageTagSession.h"
#import "SimulatedImageTagTask.h"
#import "SimulatedImageTagInstructions.h"
#import "SimulatedImageClassifier.h"

@implementation SimulatedImageTagSession

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *guitarPath = [[NSBundle mainBundle] pathForResource:@"guitar01" ofType:@"jpg"];
        NSString *planogramPath = [[NSBundle mainBundle] pathForResource:@"planogram01" ofType:@"png"];
        NSArray<NSString *> *objectClassNames = @[@"Guitar Body"];
        self.tasks = @[
                       [[SimulatedImageTagTask alloc] initWithTaskId:[[NSUUID UUID] UUIDString]
                                                                type:@"annotate"
                                                            imageURL:[NSURL fileURLWithPath:guitarPath]
                                                    objectClassNames:objectClassNames
                                                        instructions:[[SimulatedImageTagInstructions alloc] initWithText:@"Draw a box around the body of any guitars"
                                                                                                             sampleImage:[NSURL fileURLWithPath:guitarPath]]],
                       [[SimulatedImageTagTask alloc] initWithTaskId:[[NSUUID UUID] UUIDString]
                                                                type:@"annotate"
                                                            imageURL:[NSURL fileURLWithPath:planogramPath]
                                                    objectClassNames:objectClassNames
                                                        instructions:[[SimulatedImageTagInstructions alloc] initWithText:@"Draw a box around any bottles of Dash detergent."
                                                                                                             sampleImage:[NSURL fileURLWithPath:planogramPath]]]
                       ];
    }
    return self;
}

- (void)fetchNextImageTagTask:(void (^)(id <MSImageTagTask> task, NSError *error))completion
{
    SimulatedImageTagTask *request = [self.tasks objectAtIndex:self.currentTaskIndex];
    self.currentTaskIndex = (self.currentTaskIndex + 1) % self.tasks.count;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion(request, nil);
    });
}

- (void)submitResult:(id<MSImageTagResult>)result
             forTask:(id<MSImageTagTask>)task
          completion:(void (^)(NSError *error))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion(nil);
    });
}

- (id<MSImageClassifier>)imageClassifier
{
    return [[SimulatedImageClassifier alloc] init];
}

@end

