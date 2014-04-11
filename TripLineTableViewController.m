//
//  TripLineTableViewController.m
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 4/4/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "TripLineTableViewController.h"
#import "MyTripViewController.h"
#import "DataHelper.h"

@interface TripLineTableViewController ()

@property NSManagedObjectContext *context;
@property DataHelper *dataHelp;

@end

@implementation TripLineTableViewController
@synthesize agencyArray;
@synthesize context;
@synthesize dataHelp;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Initialize DataHelper
    self.dataHelp = [[DataHelper alloc] init];
    
    //Initialize the agency names into array
    self.agencyArray = [self.dataHelp getAgencyNames];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.agencyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LineCell" forIndexPath:indexPath];
    
    // Configure the cell...
    [cell.textLabel setText:[self.agencyArray objectAtIndex:indexPath.row]];
    
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0];
    cell.textLabel.textColor = [UIColor whiteColor];

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"LineCell"])
    {
        NSString *selectedAgency = [self.agencyArray objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
    
        MyTripViewController *destController = segue.destinationViewController;
        destController.agencyName = selectedAgency;
    }
    
}


@end
