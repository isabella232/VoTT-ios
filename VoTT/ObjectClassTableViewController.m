//
//  ObjectClassTableViewController.m
//  VoTT
//
//  Created by JC Jimenez on 12/6/17.
//  Copyright © 2017 Microsoft. All rights reserved.
//

#import "ObjectClassTableViewController.h"

@interface ObjectClassTableViewController ()

@end

@implementation ObjectClassTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"objectClassName"];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.task.objectClassNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"objectClassName" forIndexPath:indexPath];
    cell.textLabel.text = [self.task.objectClassNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_objectClassSelectionCompletion) {
        return;
    }
    _objectClassSelectionCompletion([self.task.objectClassNames objectAtIndex:indexPath.row]);
}

@end
