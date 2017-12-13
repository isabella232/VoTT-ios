//
//  MSPanGestureRecognizer.m
//  Image Tag
//
//  Created by JC Jimenez on 11/16/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "MSPanGestureRecognizer.h"

@interface UIPanGestureRecognizer()
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end

@implementation MSPanGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [[touches objectEnumerator] nextObject];
    self.startLocation = [touch locationInView:self.view];
}

@end
