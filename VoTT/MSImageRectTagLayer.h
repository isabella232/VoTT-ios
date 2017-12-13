//
//  MSImageRectTagLayer.h
//  Image Tag
//
//  Created by JC Jimenez on 11/16/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol MSImageTagAnnotation;
@protocol MSImageRectTagLayerTransformDelegate;

@interface MSImageRectTagLayer : CAShapeLayer

- (instancetype)initWithAnnotation:(NSObject<MSImageTagAnnotation> *)annotation transformDelegate:(id<MSImageRectTagLayerTransformDelegate>)transformDelegate;

@property (nonatomic, strong, readonly) NSObject<MSImageTagAnnotation> *annotation;
@property (nonatomic, assign, readwrite) BOOL selected;
@property (nonatomic, assign, readwrite) id<MSImageRectTagLayerTransformDelegate> transformDelegate;

@end

@protocol MSImageRectTagLayerTransformDelegate

- (CGRect)modelFrameToViewFrame:(CGRect)modelFrame;

@end

