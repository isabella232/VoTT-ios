//
//  MSImageTagDocument.m
//  Image Tag
//
//  Created by JC Jimenez on 11/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MSImageTagDocument.h"
#import <UIKit/UIKit.h>

@implementation MSImageTagDocument

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.annotations = [NSArray array];
    }
    return self;
}

@end

@implementation MSImageTagAnnotation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.annotationId = [[NSUUID UUID] UUIDString];
        self.objectBoundingBox = CGRectZero;
    }
    return self;
}

- (NSString *)description
{
    return [@{@"annotationId": self.annotationId, @"objectBoundingBox": NSStringFromCGRect(_objectBoundingBox)} description];
}

@end

