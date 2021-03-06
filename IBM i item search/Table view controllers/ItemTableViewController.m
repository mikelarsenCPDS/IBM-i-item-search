//
//  ItemTableViewController.m
//  IBM i item search
//
//  Created by Michael D Larsen on 3/17/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import "ItemTableViewController.h"
#import "ItemDetailViewController.h"

@interface ItemTableViewController ()

{
    // workfields
    
    NSArray *arrWSResponseMessage;
    NSString *strWSResponseMessage;
    NSMutableString *strItemViewTitle;
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    // fields passed from item class table view controller.  we'll pass these to the items web service
    
    NSString *itemClassIn;
    
    // fields returned from the item web service
    
    NSString *ItemNumber;
    NSString *ItemNumberDescription;
    
    NSString *strSelectedItemNumber;
    NSString *strSelectedItemClass;
    
    NSArray *downloadedItems;
    getItemModel *_getItemModel;
}

@end

@implementation ItemTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    // this removes the border
    
    //self.tableView.separatorColor = [UIColor clearColor];
    
    // this gets the application name and displays it in the title bar
    
    self.title = @"Items";
}

- (void)viewDidAppear:(BOOL)animated
{
    // set properties on the table view
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // this gets the item class and item number sent from the item class table view controller when
    // a row is selected
    
    _itemClassFromItemClassTableViewControllerSegue   = self.itemClassFromItemClassTableViewControllerSegue;
    
    itemClassIn = _itemClassFromItemClassTableViewControllerSegue;
    
    // Set this view controller object as the delegate and data source for the table view
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // this removes the border
    
    //self.tableView.separatorColor = [UIColor clearColor];
    
    self.itemsTableView.separatorColor = [UIColor darkGrayColor];
    
    // pull down refresh control
    
    UIColor *textColor = self.view.tintColor;
    
    [textColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    // Initialize the refresh control.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:*(&red) green:*(&green) blue:*(&blue) alpha:1];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshItemClasses)
                  forControlEvents:UIControlEventValueChanged];
    
    // call web service to get items to be loaded
    
    [self getItems];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)refreshItemClasses
{
    // this will execute if they pull down the item list to refresh it
    
    [self getItems];
    
    // End the refreshing
    
    if (self.refreshControl)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

- (void)getItems
{
    // ------------------------------------------------------------------------------------------------------------
    // GET ITEMS
    // ------------------------------------------------------------------------------------------------------------
    
    // Create new getItem object and assign it to getItems variable
    
    _getItemModel = [[getItemModel alloc] init];
    
    // Set this view controller object as the delegate for the getItems model object
    
    _getItemModel.delegate = self;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // Call the downloadItems method of the _getItemsModel model object
    
    [_getItemModel downloadItems:itemClassIn];
}

-(void)getItemsWS:(NSArray *)ItemsDownloaded
{
    // This delegate method will get called when the items are finished downloading
    
    // Set the downloaded items to the array
    
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
            [self.tableView reloadData];
            
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    if (downloadedItems == nil || [downloadedItems count] == 0)
    {
        // Display a message when the table is empty
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        return 1;
    }
    
    return 0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
    // this adds a header to the tableview
    // set the title of the view to include the item class they chose
    
    //strItemViewTitle = [NSMutableString string];
    
    //[strItemViewTitle appendString:@"Item class "];
    //[strItemViewTitle appendString:itemClassIn];
    
    //return strItemViewTitle;
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *vwHeader = [[UIView alloc] init];
    
    [vwHeader setTag:200 + section];
    
    switch (section)
    {
        case 0:
            [vwHeader setBackgroundColor:[UIColor colorWithRed:(181.0/255.0) green:(186.0/255.0) blue:(176.0/255.0) alpha:1]];
            
            break;
        case 1:
            [vwHeader setBackgroundColor:[UIColor redColor]];
            break;
        default:
            break;
    }
    
    UILabel *lblTitle = [[UILabel alloc] init];
    
    [lblTitle setFrame:CGRectMake(10, 0, 200, 30)];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    
    strItemViewTitle = [NSMutableString string];
    
    [strItemViewTitle appendString:@"Item class "];
    [strItemViewTitle appendString:itemClassIn];
    
    [lblTitle setText:strItemViewTitle];
    
    [vwHeader addSubview:lblTitle];
    
    return vwHeader;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [downloadedItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //-------------------------------------------------------------------------------------
    // Get the items to be shown
    //-------------------------------------------------------------------------------------
    
    getItemInfo *getItemInfo = downloadedItems[indexPath.row];
    
    // this is the info coming from the web service
    
    ItemNumber = getItemInfo.strItemNumber;
    ItemNumberDescription = getItemInfo.strItemNumberDescription;
    
    cell.textLabel.text = ItemNumber;
    
    cell.detailTextLabel.text = ItemNumberDescription;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // alternate row color
    
    if (indexPath.row%2 == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:(110.0/255.0) green:(159.0/255.0) blue:(239.0/255.0) alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor colorWithRed:(222.0/255.0) green:(227.0/255.0) blue:(234.0/255.0) alpha:1];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the tableview has an outlet in .h
    //NSIndexPath *indexPath = [self.itemTableView indexPathForSelectedRow];
    
    // get the value of the selected tableview cell.  in this case, get the user name
    UITableViewCell *cell = [self.itemsTableView cellForRowAtIndexPath:indexPath];
    
    strSelectedItemClass = itemClassIn;
    strSelectedItemNumber = cell.textLabel.text;;
    
    // when they select a row, perform the segue to the item details viewcontroller
    
    [self performSegueWithIdentifier:@"item detail segue" sender:self];
    
    // deselect row b/c the row colors didn't look right after going back to the tableviewcontroller
    
    [self.itemsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    // i control dragged from the yellow button of the table view controller to the next table view controller
    // that s/b called when they select a row.
    
    if ([[segue identifier] isEqualToString:@"item detail segue"])
    {
        ItemDetailViewController *destViewController = segue.destinationViewController;
        destViewController.itemClassFromItemTableViewControllerSegue = strSelectedItemClass;
        destViewController.itemNumberFromItemTableViewControllerSegue = strSelectedItemNumber;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
