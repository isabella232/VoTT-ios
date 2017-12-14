//
//  SimulatedImageTagTask.h
//  VoTT
//
//  Created by JC Jimenez on 12/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MSImageTagService.h"

@interface SimulatedImageTagTask : NSObject<MSImageTagTask>

@property (nonatomic, copy, readonly) NSString *taskId;
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSURL *imageURL;
@property (nonatomic, copy, readonly) NSArray<NSString *> *objectClassNames;
@property (nonatomic, strong, readonly) id <MSImageTagInstructions> instructions;

@property (nonatomic, copy, readonly) NSString *classifierSuggestion;

- (instancetype)initWithTaskId:(NSString *)requestId
                          type:(NSString *)type
                      imageURL:(NSURL *)imageURL
              objectClassNames:(NSArray<NSString *> *)objectClassNames
          classifierSuggestion:(NSString *)classifierSuggestion
                  instructions:(id <MSImageTagInstructions>)instructions;

@end

