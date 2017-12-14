//
//  MSImageTagView.m
//  Image Tag
//
//  Created by JC Jimenez on 11/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MSImageTagView.h"
#import "MSImageTagDocument.h"
#import <AVFoundation/AVFoundation.h>
#import "MSPanGestureRecognizer.h"
#import "MSImageRectTagLayer.h"

NSString *const MSImageTagViewDidTagNotification = @"MSImageTagViewDidTagNotification";

@interface MSImageTagView() <MSImageRectTagLayerTransformDelegate>

@property (nonatomic, assign) CGAffineTransform modelViewTransform;
@property (nonatomic, assign) CGAffineTransform viewModelTransform;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) MSPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) MSImageTagAnnotation *selectedAnnotation;

@end

@implementation MSImageTagView

- (void)dealloc
{
    [_panRecognizer removeTarget:self action:@selector(panRecognizerDidFire:)];
    [_document removeObserver:self forKeyPath:NSStringFromSelector(@selector(annotations))];
    [self releaseAnnotationLayers];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.autoresizesSubviews = YES;
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.autoresizesSubviews = YES;
    self.imageView.userInteractionEnabled = NO;
    [self addSubview:_imageView];
    
    self.modelViewTransform = CGAffineTransformIdentity;
    
    self.panRecognizer = [[MSPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizerDidFire:)];
    [self addGestureRecognizer:self.panRecognizer];
}

- (CGRect)modelFrameToViewFrame:(CGRect)modelFrame
{
    const CGRect result = CGRectApplyAffineTransform(modelFrame, _modelViewTransform);
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context != ((__bridge void *)[self class])) {
        return;
    }
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(annotations))]) {
        NSUInteger kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
        switch (kind) {
            case NSKeyValueChangeInsertion:
            {
                NSArray<MSImageTagAnnotation *> *annotations = [change objectForKey:NSKeyValueChangeNewKey];
                for (MSImageTagAnnotation *annotation in annotations) {
                    [self addLayerForAnnotation:annotation];
                }
                break;
            }
            case NSKeyValueChangeRemoval:
            {
                NSArray<MSImageTagAnnotation *> *annotations = [change objectForKey:NSKeyValueChangeOldKey];
                for (MSImageTagAnnotation *annotation in annotations) {
                    [self removeLayerForAnnotation:annotation];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)panRecognizerDidFire:(MSPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            const CGPoint viewLocation = [recognizer startLocation];
            const CGPoint modelLocation = CGPointApplyAffineTransform(viewLocation, _viewModelTransform);
            
            MSImageTagAnnotation *annotation = [[MSImageTagAnnotation alloc] init];
            annotation.objectBoundingBox = CGRectMake(modelLocation.x, modelLocation.y, 1, 1);
            [[self.document mutableArrayValueForKey:NSStringFromSelector(@selector(annotations))] addObject:annotation];
            
            self.selectedAnnotation = annotation;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            const CGPoint startLocation = [recognizer startLocation];
            const CGPoint locationInView = [recognizer locationInView:recognizer.view];
            const CGRect selectionInView = CGRectMake(
                                                      MIN(startLocation.x, locationInView.x),
                                                      MIN(startLocation.y, locationInView.y),
                                                      fabs(locationInView.x-startLocation.x),
                                                      fabs(locationInView.y-startLocation.y)
                                                      );
            const CGRect translationInModel = CGRectApplyAffineTransform(selectionInView, _viewModelTransform);
            self.selectedAnnotation.objectBoundingBox = translationInModel;
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            NSDictionary *userInfo = @{
                                       @"annotation": self.selectedAnnotation,
                                       @"modelRect":[NSValue valueWithCGRect:self.selectedAnnotation.objectBoundingBox],
                                       @"viewRect":[NSValue valueWithCGRect:CGRectApplyAffineTransform(self.selectedAnnotation.objectBoundingBox, _modelViewTransform)]
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:MSImageTagViewDidTagNotification object:self userInfo:userInfo];
            self.selectedAnnotation = nil;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
            NSLog(@"%s recognizer.state:%@", __FUNCTION__, @(recognizer.state));
            self.selectedAnnotation = nil;
            break;
    }
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setDocument:(MSImageTagDocument *)document
{
    [_document removeObserver:self forKeyPath:NSStringFromSelector(@selector(annotations))];
    _document = document;
    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:document.imageURL]];
    [self takeAnnotationsFromDocument];
    [self updateImageTransform];
    [_document addObserver:self forKeyPath:NSStringFromSelector(@selector(annotations)) options:NSKeyValueObservingOptionNew context:(void *)[self class]];
}

- (void)updateImageTransform
{
    const CGSize imageSize = self.imageView.image.size;
    const CGRect bounds = self.bounds;
    self.modelViewTransform = MSImageTagViewModelViewTranformForImageSizeInViewBounds(imageSize, bounds);
    self.viewModelTransform = MSImageTagViewViewModelTranformForImageSizeInViewBounds(imageSize, bounds);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self updateImageTransform];
    self.layer.frame = self.bounds;
    [self layoutSubviews];
    [self.layer layoutSublayers];
}

- (void)setSelectedAnnotation:(MSImageTagAnnotation *)selectedAnnotation
{
    [self setSelectedForAnnotationLayer:_selectedAnnotation selected:NO];
    _selectedAnnotation = selectedAnnotation;
    [self setSelectedForAnnotationLayer:_selectedAnnotation selected:YES];
}

- (void)setSelectedForAnnotationLayer:(MSImageTagAnnotation *)annotation selected:(BOOL)selected
{
    if ([annotation isKindOfClass:[MSImageTagAnnotation class]]) {
        for (CALayer *layer in self.layer.sublayers) {
            if ([layer isKindOfClass:[MSImageRectTagLayer class]]) {
                MSImageRectTagLayer *annotationLayer = ((MSImageRectTagLayer *)layer);
                if (annotationLayer.annotation == annotation) {
                    annotationLayer.selected = selected;
                    return;
                }
            }
        }
    }
}

- (void)takeAnnotationsFromDocument
{
    [self releaseAnnotationLayers];
    for (MSImageTagAnnotation *annotation in self.document.annotations) {
        [self addLayerForAnnotation:annotation];
    }
}

- (void)releaseAnnotationLayers
{
    NSArray *annotationLayers = [self.layer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id layer, NSDictionary *bindings) {
        return [layer isKindOfClass:[MSImageRectTagLayer class]];
    }]];
    for (MSImageRectTagLayer *layer in annotationLayers) {
        layer.transformDelegate = nil;
        [layer removeFromSuperlayer];
    }
}

- (void)addLayerForAnnotation:(MSImageTagAnnotation *)annotation
{
    if ([annotation isKindOfClass:[MSImageTagAnnotation class]]) {
        MSImageRectTagLayer *shapeLayer = [[MSImageRectTagLayer alloc] initWithAnnotation:(MSImageTagAnnotation *)annotation transformDelegate:self];
        [self.layer addSublayer:shapeLayer];
    }
}

- (void)removeLayerForAnnotation:(MSImageTagAnnotation *)annotation
{
    NSArray *annotationLayers = [self.layer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id layer, NSDictionary<NSString *,id> *bindings) {
        return ([layer isKindOfClass:[MSImageRectTagLayer class]] && ((MSImageRectTagLayer *)layer).annotation == annotation);
    }]];
    [annotationLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

@end

CGAffineTransform MSImageTagViewModelViewTranformForImageSizeInViewBounds(CGSize imageSize, CGRect bounds)
{
    if (imageSize.width < 1.0 || bounds.size.width < 1.0) {
        return CGAffineTransformIdentity;
    }
    const CGRect imageFrame = AVMakeRectWithAspectRatioInsideRect(imageSize, bounds);
    const CGPoint scale = CGPointMake(imageFrame.size.width/imageSize.width, imageFrame.size.height/imageSize.height);
    
    CGAffineTransform modelViewTransform = CGAffineTransformMakeTranslation(imageFrame.origin.x, imageFrame.origin.y);
    return CGAffineTransformScale(modelViewTransform, scale.x, scale.y);
}

CGAffineTransform MSImageTagViewViewModelTranformForImageSizeInViewBounds(CGSize imageSize, CGRect bounds)
{
    if (imageSize.width < 1.0 || bounds.size.width < 1.0) {
        return CGAffineTransformIdentity;
    }
    const CGRect imageFrame = AVMakeRectWithAspectRatioInsideRect(imageSize, bounds);
    const CGPoint scale = CGPointMake(imageFrame.size.width/imageSize.width, imageFrame.size.height/imageSize.height);
    
    CGAffineTransform viewModelTransform = CGAffineTransformMakeScale(1.0/scale.x, 1.0/scale.y);
    return CGAffineTransformTranslate(viewModelTransform, -imageFrame.origin.x, -imageFrame.origin.y);
}
