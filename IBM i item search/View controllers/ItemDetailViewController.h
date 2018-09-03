//
//  ItemDetailViewController.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/24/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "getItemDetailModel.h"
#import "getItemDetailInfo.h"

@interface ItemDetailViewController : UIViewController <getItemDetailModelProtocol>

@property (strong, nonatomic) NSString *itemClassFromItemTableViewControllerSegue;
@property (strong, nonatomic) NSString *itemNumberFromItemTableViewControllerSegue;
@property (strong, nonatomic) IBOutlet UILabel *lblItemNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblItemClass;
@property (strong, nonatomic) IBOutlet UILabel *lblItemDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblUnitOfMeasure;
@property (strong, nonatomic) IBOutlet UIView *itemDetailsView;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@end
