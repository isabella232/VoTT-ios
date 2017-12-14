//
//  SimulatedImageTagInstructions.h
//  VoTT
//
//  Created by JC Jimenez on 12/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MSImageTagService.h"

@interface SimulatedImageTagInstructions : NSObject<MSImageTagInstructions>

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSURL *sampleImage;

- (instancetype)initWithText:(NSString *)text sampleImage:(NSURL *)sampleImage;

@end


