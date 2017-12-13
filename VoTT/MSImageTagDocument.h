//
//  MSImageTagDocument.h
//  Image Tag
//
//  Created by JC Jimenez on 11/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MSImageTagService.h"

@class MSImageTagAnnotation;
@class MSImageTagDocument;

@interface MSImageTagDocument : NSObject <MSImageTagResult>

@property (nonatomic, strong, readwrite) NSURL *imageURL;
@property (nonatomic, copy, readwrite) NSArray<id <MSImageTagAnnotation>> *annotations;

@end

@interface MSImageTagAnnotation : NSObject <MSImageTagAnnotation>

@property (nonatomic, copy, readwrite) NSString *annotationId;
@property (nonatomic, copy, readwrite) NSString *objectClass;
@property (nonatomic, assign, readwrite) CGRect objectBoundingBox;

@end
