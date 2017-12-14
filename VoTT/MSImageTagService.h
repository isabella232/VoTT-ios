//
//  ImageTagService.h
//  Image Tag
//
//  Created by JC Jimenez on 11/17/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol MSImageTagService;
@protocol MSImageTagSession;

@protocol MSImageTagTask;
@protocol MSImageTagInstructions;

@protocol MSImageClassifier;

@protocol MSImageTagResult;
@protocol MSImageTagAnnotation;

@protocol MSImageTagService <NSObject>

- (void)startSession:(NSURL *)url
          completion:(void (^)(id <MSImageTagSession> session, NSError *error))completion;

@end

@protocol MSImageTagSession <NSObject>

- (void)fetchNextImageTagTask:(void (^)(id <MSImageTagTask> task, NSError *error))completion;
- (void)submitResult:(id<MSImageTagResult>)result
             forTask:(id<MSImageTagTask>)task
          completion:(void (^)(NSError *error))completion;
- (id <MSImageClassifier>)imageClassifier;

@end

@protocol MSImageTagTask <NSObject>

/**
 * May be set to @"annotate" (default) or @"classify".
 */
@property (nonatomic, copy, readonly) NSString *type;
@property (nonatomic, copy, readonly) NSString *taskId;
@property (nonatomic, copy, readonly) NSURL *imageURL;
@property (nonatomic, copy, readonly) NSArray<NSString *> *objectClassNames;

/**
 * Optional set of instructions coming from the project owner.
 */
@property (nonatomic, strong, readonly) id <MSImageTagInstructions> instructions;

@end

@protocol MSImageTagInstructions <NSObject>

@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSURL *sampleImage;

@end

@protocol MSImageClassifier <NSObject>

- (void)classifyImageData:(NSData *)image
               completion:(void (^)(NSString *classNamePrediction, NSError *error))completion;

@end

@protocol MSImageTagResult <NSObject>

@property (nonatomic, copy, readonly) NSArray<id <MSImageTagAnnotation>> *annotations;

@end

@protocol MSImageTagAnnotation <NSObject>

@property (nonatomic, copy, readonly) NSString *annotationId;
@property (nonatomic, copy, readwrite) NSString *objectClass;
@property (nonatomic, assign, readonly) CGRect objectBoundingBox;

@end

