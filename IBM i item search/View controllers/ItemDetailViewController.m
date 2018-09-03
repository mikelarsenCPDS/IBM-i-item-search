//
//  ItemDetailViewController.m
//  IBM i item search
//
//  Created by Michael D Larsen on 3/24/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import "ItemDetailViewController.h"

@interface ItemDetailViewController ()

{
    // workfields
    
    NSArray *arrWSResponseMessage;
    NSString *strWSResponseMessage;
    NSMutableAttributedString *attributedDescriptionString;
    NSMutableAttributedString *attributedTitleString;
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    // fields passed from item table view controller.  we'll pass these to the item details web service
    
    NSString *itemClassIn;
    NSString *itemNumberIn;
    
    NSArray *downloadedItems;
    getItemDetailModel *_getItemDetailModel;
}

@end

@implementation ItemDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"Item detail";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.

    //UIColor *color = [[UIColor alloc]initWithRed:110.0/255.0 green:159.0/255.0 blue:239.0/255.0 alpha:1.0];
    
    //_itemDetailView.backgroundColor = color;
    
    _lblItemDescription.numberOfLines = 0;
    
    // this gets the item class and item number sent from the item table view controller when
    // a row is selected
    
    _itemClassFromItemTableViewControllerSegue  = self.itemClassFromItemTableViewControllerSegue;
    _itemNumberFromItemTableViewControllerSegue = self.itemNumberFromItemTableViewControllerSegue;
    
    itemClassIn  = _itemClassFromItemTableViewControllerSegue;
    itemNumberIn = _itemNumberFromItemTableViewControllerSegue;
    
    // call web service to get item details to be loaded
    
    [self getItemDetails];
}

- (void)getItemDetails
{
    // ------------------------------------------------------------------------------------------------------------
    // GET ITEM DETAILS
    // ------------------------------------------------------------------------------------------------------------
    
    // Create new getItemDetail object and assign it to getItemDetails variable
    
    _getItemDetailModel = [[getItemDetailModel alloc] init];
    
    // Set this view controller object as the delegate for the getItemDetail model object
    
    _getItemDetailModel.delegate = self;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Call the downloadItemDetails method of the _getItemDetailModel model object
    
    [_getItemDetailModel downloadItemDetails:itemClassIn withItemNumber:itemNumberIn];
}

-(void)getItemDetailsWS:(NSArray *)ItemsDownloaded
{
    // This delegate method will get called when the items are finished downloading
    
    // Set the downloaded item details to the array
    
    downloadedItems = ItemsDownloaded;
    
    // i will only populate the response if:
    //
    // 1.  you couldn't connect to the service
    // 2.  there are actual items to download
    
    if (downloadedItems == nil || [downloadedItems count] == 0)
    {
        
    }
    else
    {
        arrWSResponseMessage = [downloadedItems valueForKey:@"WSResponseMessage"];
        strWSResponseMessage = [arrWSResponseMessage objectAtIndex:0];
    }
    
    if ([strWSResponseMessage isEqualToString:@"Can't connect to server"])
    {
        // after calling web service, you need to call dispatch_async on anything UI related otherwise it hangs
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // if you get a bad response from the server, put up an alert
            
            [self connectionToServerAlert];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        });
    }
    else
    {
        // after calling web service, you need to call dispatc_async on anything UI related otherwise it hangs
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // we know we will only get one message back in the response, so just get the first element from the array object
            
            if([self->downloadedItems count] != 0)
            {
                getItemDetailInfo *getItemDetailInfo = self->downloadedItems[0];
                    
                self->_lblItemNumber.text      = getItemDetailInfo.strItemNumberDetail;
                self->_lblItemClass.text       = getItemDetailInfo.strItemClassDetail;
                self->_lblUnitOfMeasure.text   = getItemDetailInfo.strUnitOfMeasureDetail;
                //_lblItemDescription.text = getItemDetailInfo.strItemNumberDescriptionDetail;
                
                // get the font size for the description label.
                
                CGFloat descFontSize = self->_lblItemDescription.font.pointSize;
                
                // make the 'item description' text an attributed string
                
                self->attributedDescriptionString = [[NSMutableAttributedString alloc] initWithString:getItemDetailInfo.strItemNumberDescriptionDetail];
                
                NSUInteger attributedDescriptionStringLength = [self->attributedDescriptionString length];
                
                [self->attributedDescriptionString setAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:descFontSize]} range:NSMakeRange(0, attributedDescriptionStringLength)];
                
                self->_lblItemDescription.text = @"";
                self->_lblItemDescription.attributedText = self->attributedDescriptionString;
                
                [self->_lblItemDescription sizeToFit];
                
                // make the title text an attributed string
                // get the font size for the title label.
                
                CGFloat titleFontSize = self->_lblTitle.font.pointSize;
                
                self->attributedTitleString = [[NSMutableAttributedString alloc] initWithString:@"Item details"];
                
                NSUInteger attributedTitleStringLength = [self->attributedTitleString length];
                
                [self->attributedTitleString setAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont systemFontOfSize:titleFontSize]} range:NSMakeRange(0, attributedTitleStringLength)];
                
                [self->attributedTitleString addAttribute:NSUnderlineStyleAttributeName
                                              value:[NSNumber numberWithInt:1]
                                                    range:(NSRange){0,[self->attributedTitleString length]}];
                
                self->_lblTitle.text = @"";
                self->_lblTitle.attributedText = self->attributedTitleString;
                [self->_lblTitle sizeToFit];
                    
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
            else
            {
                self->_lblItemNumber.text      = @"";
                self->_lblItemClass.text       = @"";
                self->_lblUnitOfMeasure.text   = @"";
                self->_lblItemDescription.text = @"";
            }
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }
}

- (void)connectionToServerAlert
{
    // put up an laert if there was an issue connecitng to the server
    
    UIAlertController *alert =   [UIAlertController
                                  alertControllerWithTitle:@"Connection issue"
                                  message:@"Can't connect to server"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Ok"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
