//
//  MSImageRectTagLayer.m
//  Image Tag
//
//  Created by JC Jimenez on 11/16/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MSImageRectTagLayer.h"
#import "MSImageTagDocument.h"
#import <UIKit/UIKit.h>

NSString *const MSImageRectTagLayerRectKeyPath = @"objectBoundingBox";

@implementation MSImageRectTagLayer

- (void)dealloc
{
    [_annotation removeObserver:self forKeyPath:MSImageRectTagLayerRectKeyPath];
}

- (instancetype)initWithAnnotation:(NSObject<MSImageTagAnnotation> *)annotation transformDelegate:(id<MSImageRectTagLayerTransformDelegate>)transformDelegate
{
    self = [super init];
    if (self) {
        _transformDelegate = transformDelegate;
        _annotation = annotation;
        [_annotation addObserver:self forKeyPath:NSStringFromSelector(@selector(objectBoundingBox)) options:0 context:(__bridge void *)[self class]];
        
        self.fillColor = [UIColor clearColor].CGColor;
        self.strokeColor = [UIColor redColor].CGColor;
        self.lineWidth = 4.0;
        self.lineJoin = kCALineJoinRound;
        self.path = [UIBezierPath bezierPathWithRect:self.annotation.objectBoundingBox].CGPath;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected) {
        self.lineDashPattern = @[@(10), @(5)];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        
        [animation setFromValue:@(0.0f)];
        [animation setToValue:@(16.0f)];
        [animation setDuration:0.25f];
        [animation setRepeatCount:MAXFLOAT];
        
        [self addAnimation:animation forKey:@"linePhase"];
    }
    else {
        [self removeAnimationForKey:@"linePhase"];
        self.lineDashPattern = @[];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context != ((__bridge void *)[self class])) {
        return;
    }
    
    if ([keyPath isEqualToString:MSImageRectTagLayerRectKeyPath]) {
        const CGRect pathFrame = [_transformDelegate modelFrameToViewFrame:_annotation.objectBoundingBox];
        self.path = [UIBezierPath bezierPathWithRect:pathFrame].CGPath;
    }
}

@end

