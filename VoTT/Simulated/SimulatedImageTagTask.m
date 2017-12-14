//
//  SimulatedImageTagTask.m
//  VoTT
//
//  Created by JC Jimenez on 12/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "SimulatedImageTagTask.h"

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

