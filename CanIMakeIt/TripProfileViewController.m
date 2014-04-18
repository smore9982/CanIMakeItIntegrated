//
//  TripProfileViewController.m
//  CanIMakeIt
//
//  Created by DAKSHAYANI PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "TripProfileViewController.h"
#import "MyTripViewController.h"
#import "TripDetailViewController.h"
#import "DataHelper.h"

@interface TripProfileViewController ()

@property DataHelper *getDataHelper;
@property NSManagedObjectContext *managedObjectContext;
@property NSArray *allAgencyNames;
@property NSArray *allAgencyId;
@property NSDictionary *agencyModel;
@property NSMutableDictionary *agencySplitModel;
@property NSString *savedDefaultTripID;


@end

@implementation TripProfileViewController
@synthesize getDataHelper;
@synthesize contactdb;
@synthesize managedObjectContext;
@synthesize allAgencyNames;
@synthesize allAgencyId;
@synthesize agencyModel;
@synthesize agencySplitModel;
@synthesize savedDefaultTripID;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
    
    //Initialize DataHelper
    self.getDataHelper = [[DataHelper alloc] init];
    
    //fetch from persistent data store
    self.managedObjectContext = [self.getDataHelper managedObjectContext];
    
    //Get ObjectID of default Trip profile
    savedDefaultTripID = [self.getDataHelper getUserData:@"defaultTripID"];
    
    //Get Agency Information
    self.agencyModel = [self.getDataHelper getAgencyData];
    self.allAgencyId = [self.agencyModel allKeys];
    self.allAgencyNames = [self.agencyModel allValues];
    
    self.agencySplitModel = [[NSMutableDictionary alloc] initWithObjects:self.allAgencyNames forKeys:self.allAgencyNames];
    
    
    NSError *error= nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Trips"];
    
    self.tripArray = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (self.tripArray.count == 0)
    {
        UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"0 Trips" message:@"No Trip has been created yet!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertUser show];
        [alertUser reloadInputViews];
    }
    else
    {
        //Get Trip Profiles for each agency
        for (int i = 0; i < self.allAgencyId.count; i++)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"agencyId = %@",self.allAgencyId[i]];
            [fetchRequest setPredicate:predicate];
            
            NSError *error1= nil;
            NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error1];
            
            if(array==nil || [array count] <=0){
                continue;
            }
            
            NSArray *splitTrips = [[NSArray alloc] init];
            splitTrips = array;
            //for (int j = 0; j < array.count; j++) {
            //    NSManagedObject *tripData = [array objectAtIndex:j];
                //NSString *tripProfile = [[NSString alloc] initWithFormat:@"%@-%@", [tripData valueForKey:@"fromStation"], [tripData valueForKey:@"toStation"]];
                
                //NSLog(@"trip profile %d, %d- %@", i, j, tripProfile);
                //[splitTrips addObject:[array objectAtIndex:j]];
              //   NSLog(@"trip profile array- %@", splitTrips);
            //}
            
            if(splitTrips.count > 0)
            {
                [self.agencySplitModel setObject:splitTrips forKey:self.allAgencyNames[i]];
                //NSArray *tArray = self.agencySplitModel[self.allAgencyNames[i]];
               // NSLog(@" before tarray - %@, %d", tArray, tArray.count);
            }
        }
        
    }
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.allAgencyNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tArray = [self.agencySplitModel objectForKey:self.allAgencyNames[section]];
    
    return tArray.count;

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.tripArray.count == 0)
        return 0;
    
    return self.allAgencyNames[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Retrieve trips for each agency in an array
    NSArray *trip = self.agencySplitModel[self.allAgencyNames[indexPath.section]];
    
    //Retrieve each trip for each cell
    self.contactdb = [trip objectAtIndex:indexPath.row];
        
    [cell.textLabel setText:[NSString stringWithFormat:@"%@-%@", [self.contactdb valueForKey:@"fromStation"], [self.contactdb valueForKey:@"toStation"]]];
        
    //Below code checks for the default trip id, and sets the checkmark appropriately.
    //Gets the object ID that uniquely identifies a row in table - Trips
    NSManagedObjectID *tripurl = [self.contactdb objectID];
    NSURL *objecturl = [tripurl URIRepresentation];
    NSString *retrievedObjectUrlString = [objecturl absoluteString];

    
    //Trip Detail disclosure
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    //Set font size, color and type
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if(![retrievedObjectUrlString compare:savedDefaultTripID])
    {
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:19.0];
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    TripDetailViewController *destViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TripDetailViewController"];
    

    NSArray *trip = self.agencySplitModel[self.allAgencyNames[indexPath.section]];
    
    NSManagedObject *selectedDevice = [trip objectAtIndex:indexPath.row];
    destViewController.contactdb = selectedDevice;
    
    
    [self presentViewController:destViewController animated:YES completion:nil];
}


//#pragma mark - Navigation
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *trip = self.agencySplitModel[self.allAgencyNames[[[self.tableView indexPathForSelectedRow] section]]];
    
    
    
    if([trip count] > 0 )
    {
        
        NSManagedObject *selectedTrip = [trip objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        
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
