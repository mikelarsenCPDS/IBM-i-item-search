//
//  ItemTableViewController.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/17/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "getItemModel.h"
#import "getItemInfo.h"

@interface ItemTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, getItemModelProtocol>

@property (strong, nonatomic) IBOutlet UITableView *itemsTableView;

@property (strong, nonatomic) NSString *itemClassFromItemClassTableViewControllerSegue;

@end
