//
//  MSImageTagView.h
//  Image Tag
//
//  Created by JC Jimenez on 11/13/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const MSImageTagViewDidTagNotification;

@class MSImageTagDocument;

@interface MSImageTagView : UIView

@property (nonatomic, strong) MSImageTagDocument *document;

@end

CGAffineTransform MSImageTagViewModelViewTranformForImageSizeInViewBounds(CGSize imageSize, CGRect viewBounds);
CGAffineTransform MSImageTagViewViewModelTranformForImageSizeInViewBounds(CGSize imageSize, CGRect viewBounds);
