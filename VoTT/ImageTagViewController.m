//
//  ImageTagViewController.m
//  VoTT
//
//  Created by JC Jimenez on 12/12/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ImageTagViewController.h"
#import "MSImageTagView.h"
#import "MSImageTagService.h"
#import "ObjectClassTableViewController.h"
#import "MSImageTagDocument.h"
#import "MBProgressHUD.h"

@interface ImageTagViewController ()

@property (strong, nonatomic) NSObject<MSImageTagTask> *task;

@property (weak, nonatomic) IBOutlet MSImageTagView *imageTagView;
@property (weak, nonatomic) IBOutlet UITextView *instructionsText;

@end

@implementation ImageTagViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageTagViewDidTagNotification:) name:MSImageTagViewDidTagNotification object:self.imageTagView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __block ImageTagViewController *blockSelf = self;
    MBProgressHUD *saveHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    saveHUD.label.text = @"Loading Task...";
    [self.session fetchNextImageTagTask:^(id<MSImageTagTask> task, NSError *error) {
        [saveHUD hideAnimated:YES];
        blockSelf.task = task;
    }];
}

- (void)setTask:(NSObject<MSImageTagTask> *)task
{
    _task = task;
    MSImageTagDocument *document = [[MSImageTagDocument alloc] init];
    document.imageURL = task.imageURL;
    self.imageTagView.document = document;
    self.instructionsText.text = task.instructions.text;
}

- (IBAction)save:(id)sender
{
    __block ImageTagViewController *blockSelf = self;
    MBProgressHUD *saveHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    saveHUD.label.text = @"Saving...";
    [self.session submitResult:nil forTask:self.task completion:^(NSError *error) {
        saveHUD.label.text = @"Loading Next...";
        [blockSelf.session fetchNextImageTagTask:^(id<MSImageTagTask> task, NSError *error) {
            [saveHUD hideAnimated:YES];
            blockSelf.task = task;
        }];
    }];
}

- (void)imageTagViewDidTagNotification:(NSNotification *)notification
{
    const CGRect modelRect = [[notification.userInfo objectForKey:@"modelRect"] CGRectValue];
    UIImage *image = self.imageTagView.image;
    CGImageRef drawImage = CGImageCreateWithImageInRect(image.CGImage, modelRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);

    ObjectClassTableViewController *selectionController = [[ObjectClassTableViewController alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *jpeg = UIImageJPEGRepresentation(croppedImage, 0.85);
#if TARGET_IPHONE_SIMULATOR
        [jpeg writeToFile:@"/tmp/vott.simulator.selection.jpg" atomically:NO];
#endif
        [[self.session imageClassifier] classifyImageData:jpeg completion:^(NSDictionary *prediction, NSError *error) {
            if (error) {
                NSLog(@"Encountered error when attempting to classify image selection: %@", error);
                return;
            }
            if (!selectionController.selectedClassName) {
                NSArray *predictions = [prediction objectForKey:@"Predictions"];
                if (predictions.count) {
                    NSDictionary *prediction = [predictions objectAtIndex:0];
                    selectionController.selectedClassName = [prediction objectForKey:@"Tag"];
                }
            }
        }];
    });

    
//    const CGRect viewRect = [[notification.userInfo objectForKey:@"viewRect"] CGRectValue];
//    selectionController.modalPresentationStyle = UIModalPresentationPopover;
//    selectionController.preferredContentSize = CGSizeMake(200, 200);
//    [selectionController setObjectClassSelectionCompletion:^(NSString *objectClassName) {
//    }];
//    [self presentViewController:selectionController animated:YES completion:^{
//    }];
//
//    selectionController.popoverPresentationController.canOverlapSourceViewRect = YES;
//    selectionController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    selectionController.popoverPresentationController.sourceView = self.imageTagView;
//    selectionController.popoverPresentationController.sourceRect = viewRect;
}

@end
