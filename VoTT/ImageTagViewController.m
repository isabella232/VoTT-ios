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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
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
    NSLog(@"%s", __FUNCTION__);
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
//    [self tag:sender];
}

- (IBAction)tag:(id)sender
{
    ObjectClassTableViewController *selectionController = [[ObjectClassTableViewController alloc] init];
    selectionController.modalPresentationStyle = UIModalPresentationPopover;
    [selectionController setObjectClassSelectionCompletion:^(NSString *objectClassName) {
    }];
    [self presentViewController:selectionController animated:YES completion:^{
    }];
    
    selectionController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    selectionController.popoverPresentationController.sourceView = self.view;
    selectionController.popoverPresentationController.sourceRect = CGRectMake(0,
                                                                              self.view.bounds.size.height/2.0,
                                                                              self.view.bounds.size.width,
                                                                              self.view.bounds.size.height/2.0);
}

@end
