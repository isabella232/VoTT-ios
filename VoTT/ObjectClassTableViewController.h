//
//  ObjectClassTableViewController.h
//  VoTT
//
//  Created by JC Jimenez on 12/6/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSImageTagService.h"

typedef void(^ObjectClassTableViewControllerClassNameSelected)(NSString *objectClassName);

@interface ObjectClassTableViewController : UITableViewController

@property (nonatomic, strong) id <MSImageTagTask> task;
@property (nonatomic, strong) ObjectClassTableViewControllerClassNameSelected objectClassSelectionCompletion;

@end
