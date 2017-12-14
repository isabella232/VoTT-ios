//
//  SimulatedImageTagInstructions.m
//  VoTT
//
//  Created by JC Jimenez on 12/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "SimulatedImageTagInstructions.h"

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

