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

@interface ImageTagViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSObject<MSImageTagTask> *task;
@property (strong, nonatomic) NSObject<MSImageTagAnnotation> *annotation;

@property (weak, nonatomic) IBOutlet MSImageTagView *imageTagView;
@property (weak, nonatomic) IBOutlet UITextView *instructionsText;
@property (weak, nonatomic) IBOutlet UIPickerView *objectClassPickerView;
@end

@implementation ImageTagViewController

- (void)dealloc
{
    _objectClassPickerView.delegate = nil;
    _objectClassPickerView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageTagViewDidTagNotification:) name:MSImageTagViewDidTagNotification object:self.imageTagView];
    
    self.objectClassPickerView.dataSource = self;
    self.objectClassPickerView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hideClassNamePicker];
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
    [self.objectClassPickerView reloadAllComponents];
}

- (void)saveSelectedAnnotationObjectClass
{
    if (self.annotation && !self.annotation.objectClass) {
        const NSUInteger rowIndex = [self.objectClassPickerView selectedRowInComponent:0];
        if (rowIndex != -1) {
            self.annotation.objectClass = [self.task.objectClassNames objectAtIndex:rowIndex];
        }
        else {
            self.annotation.objectClass = [self.task.objectClassNames objectAtIndex:0];
        }
    }
}

- (IBAction)save:(id)sender
{
    [self saveSelectedAnnotationObjectClass];
    
    __block ImageTagViewController *blockSelf = self;
    [UIView animateWithDuration:0.25
                     animations:^{
                         [self hideClassNamePicker];
                     }
                     completion:^(BOOL finished) {
                         MBProgressHUD *saveHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                         saveHUD.label.text = @"Saving...";
                         [self.session submitResult:nil forTask:self.task completion:^(NSError *error) {
                             saveHUD.label.text = @"Loading Next...";
                             [blockSelf.session fetchNextImageTagTask:^(id<MSImageTagTask> task, NSError *error) {
                                 [saveHUD hideAnimated:YES];
                                 blockSelf.task = task;
                             }];
                         }];
                     }];
}

- (void)imageTagViewDidTagNotification:(NSNotification *)notification
{
    [self saveSelectedAnnotationObjectClass];

    self.annotation = [notification.userInfo objectForKey:@"annotation"];
    const CGRect modelRect = [[notification.userInfo objectForKey:@"modelRect"] CGRectValue];
    UIImage *image = self.imageTagView.image;
    CGImageRef drawImage = CGImageCreateWithImageInRect(image.CGImage, modelRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);

    [UIView animateWithDuration:0.25 animations:^{
        [self showClassNamePicker];
    }];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *jpeg = UIImageJPEGRepresentation(croppedImage, 0.85);
#if TARGET_IPHONE_SIMULATOR
        [jpeg writeToFile:@"/tmp/vott.simulator.selection.jpg" atomically:NO];
#endif
        [[self.session imageClassifier] classifyImageData:jpeg completion:^(NSString *prediction, NSError *error) {
            if (error) {
                NSLog(@"Encountered error when attempting to classify image selection: %@", error);
                return;
            }
            if (!self.annotation.objectClass) {
                self.annotation.objectClass = prediction;
                const NSUInteger rowIndex = [self.task.objectClassNames indexOfObject:prediction];
                [self.objectClassPickerView selectRow:rowIndex inComponent:0 animated:YES];
            }
        }];
    });
}

- (CGFloat)bottomPaneHeight
{
    return 92.0;
}

- (void)hideClassNamePicker
{
    const CGFloat bottomHeight = [self bottomPaneHeight];
    self.instructionsText.alpha = 1.0;
    self.imageTagView.frame = CGRectMake(0,
                                         0,
                                         self.view.bounds.size.width,
                                         self.view.bounds.size.height-bottomHeight);
    self.instructionsText.frame = CGRectMake(0,
                                             self.view.bounds.size.height-bottomHeight,
                                             self.view.bounds.size.width,
                                             bottomHeight);
    self.objectClassPickerView.frame = CGRectMake(0,
                                                  self.view.bounds.size.height,
                                                  self.objectClassPickerView.bounds.size.width,
                                                  bottomHeight);
}

- (void)showClassNamePicker
{
    const CGFloat bottomHeight = [self bottomPaneHeight];
    self.instructionsText.alpha = 0.0;
    self.imageTagView.frame = CGRectMake(0,
                                         0,
                                         self.view.bounds.size.width,
                                         self.view.bounds.size.height-bottomHeight);
    self.objectClassPickerView.frame = CGRectMake(0,
                                                  self.view.bounds.size.height-bottomHeight,
                                                  self.objectClassPickerView.bounds.size.width,
                                                  bottomHeight);
}

#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.task.objectClassNames.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.task.objectClassNames objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.annotation.objectClass = [self.task.objectClassNames objectAtIndex:row];
    [UIView animateWithDuration:0.25 animations:^{
        [self hideClassNamePicker];
    }];
}

@end
