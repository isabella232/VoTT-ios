//
//  SimulatedImageTagService.m
//  Image Tag
//
//  Created by JC Jimenez on 11/17/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "SimulatedImageTagService.h"
#import <UIKit/UIKit.h>

@interface SimulatedImageTagSession : NSObject<MSImageTagSession>

@property (nonatomic, strong) NSArray<id <MSImageTagTask>> *tasks;
@property (nonatomic, assign) NSUInteger currentTaskIndex;

@end

@interface SimulatedImageTagTask : NSObject<MSImageTagTask>

@property (nonatomic, copy, readonly) NSString *taskId;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSURL *imageURL;
@property (nonatomic, copy, readonly) NSArray<NSString *> *objectClassNames;
@property (nonatomic, strong, readonly) id <MSImageTagInstructions> instructions;

- (instancetype)initWithTaskId:(NSString *)requestId
                          type:(NSString *)type
                         imageURL:(NSURL *)imageURL
                 objectClassNames:(NSArray<NSString *> *)objectClassNames
                     instructions:(id <MSImageTagInstructions>)instructions;

@end

@interface SimulatedImageTagInstructions : NSObject<MSImageTagInstructions>

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSURL *sampleImage;

- (instancetype)initWithText:(NSString *)text sampleImage:(NSURL *)sampleImage;

@end

@implementation SimulatedImageTagService

- (void)startSession:(NSURL *)url
          completion:(void (^)(id <MSImageTagSession> session, NSError *error))completion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion([[SimulatedImageTagSession alloc] init], nil);
    });
}

@end

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

@end

@implementation SimulatedImageTagTask

- (instancetype)initWithTaskId:(NSString *)requestId
                          type:(NSString *)type
                      imageURL:(NSURL *)imageURL
              objectClassNames:(NSArray<NSString *> *)objectClassNames
                  instructions:(id <MSImageTagInstructions>)instructions
{
    self = [super init];
    if (self) {
        _taskId = requestId;
        _type = type;
        _imageURL = imageURL;
        _instructions = instructions;
    }
    return self;
}

@end

@implementation SimulatedImageTagInstructions

- (instancetype)initWithText:(NSString *)text sampleImage:(NSURL *)sampleImage
{
    self = [super init];
    if (self) {
        _text = text;
        _sampleImage = sampleImage;
    }
    return self;
}

@end


