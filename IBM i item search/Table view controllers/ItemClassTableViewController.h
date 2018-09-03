//
//  ItemClassTableViewController.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/11/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "getItemClassModel.h"
#import "getItemClassInfo.h"

@interface ItemClassTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, getItemClassModelProtocol>

@property (strong, nonatomic) IBOutlet UITableView *itemTableView;

@end
