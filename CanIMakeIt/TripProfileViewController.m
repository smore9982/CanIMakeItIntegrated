//
//  TripProfileViewController.m
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "TripProfileViewController.h"
#import "MyTripViewController.h"
#import "TripDetailViewController.h"
#import "DataHelper.h"

@interface TripProfileViewController ()

@property DataHelper *getDataHelper;
@property NSManagedObjectContext *managedObjectContext;


@end

@implementation TripProfileViewController
@synthesize getDataHelper;
@synthesize contactdb;
@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //Initialize DataHelper
    self.getDataHelper = [[DataHelper alloc] init];
    
    //fetch from persistent data store
    self.managedObjectContext = [self.getDataHelper managedObjectContext];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Trips"];
        
    self.tripArray = [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tripArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Inside cell view");
    
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
     self.contactdb = [self.tripArray objectAtIndex:indexPath.row];
    
    
        [cell.textLabel setText:[NSString stringWithFormat:@"%@-%@",[self.contactdb valueForKey:@"fromStation"], [self.contactdb valueForKey:@"toStation"]]];
    
        //Trip Detail disclosure
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
        //Below code checks for the default trip id, and sets the checkmark appropriately.
        NSManagedObjectID *tripurl = [self.contactdb objectID];
        //Gets the object ID that uniquely identifies a row in table - Trips
        NSURL *objecturl = [tripurl URIRepresentation];
        NSString *retrievedObjectUrlString = [objecturl absoluteString];
    
        DataHelper *getTripIDHelper = [[DataHelper alloc] init];
        NSString *savedDefaultTripID = [getTripIDHelper getUserData:@"defaultTripID"];
    
    
        //NSLog(@"def id -%@, tripid - %@", savedDefaultTripID, retrievedObjectUrlString);
        
        if(![retrievedObjectUrlString compare:savedDefaultTripID])
        {
            cell.textLabel.font = [UIFont boldSystemFontOfSize:19.0];
        }
    
    
    
    return cell;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    TripDetailViewController *destViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TripDetailViewController"];
    
    NSManagedObject *selectedDevice = [self.tripArray objectAtIndex:indexPath.row];
    destViewController.contactdb = selectedDevice;
    
    
    [self presentViewController:destViewController animated:YES completion:nil];
}


//#pragma mark - Navigation
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([self.tripArray count] > 0 ){
        
        NSManagedObject *selectedTrip = [self.tripArray objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        
        NSManagedObjectID *tripObject = [selectedTrip objectID];
        NSURL *objecturl = [tripObject URIRepresentation];
        NSString *objectUrlString = [objecturl absoluteString];
        
        //Saving Default Trip object url to database context
        DataHelper *saveDataHelper = [[DataHelper alloc] init];
        [saveDataHelper saveUserData:@"defaultTripID" withValue:objectUrlString];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //Delete object from database
        [self.managedObjectContext deleteObject:[self.tripArray objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Delete the row from the data source
        [self.tripArray removeObjectAtIndex:indexPath.row];
        //Delete row from table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    
}



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


@end
