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
    self.view.backgroundColor = [UIColor colorWithRed:0.226394 green:0.696649 blue:1.0 alpha:1.0];

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
            
            //No trips for a particular agency. Hence object remains same as key.
            if(array==nil || [array count] <=0){
                continue;
            }
            
            NSMutableArray *splitTrips = [[NSMutableArray alloc] initWithArray:array];
            
            //Add trip array as object only trips exist.
            if(splitTrips.count > 0)
            {
                [self.agencySplitModel setObject:splitTrips forKey:self.allAgencyNames[i]];
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
    if (self.tripArray.count == 0)
        return 0;
    
    NSArray *tArray = [self.agencySplitModel objectForKey:self.allAgencyNames[section]];
    
    //Return 0 if key == object. no trips for an agency
    if ([tArray isEqual:self.allAgencyNames[section]]) {
        return 0;
    }
    
    return tArray.count;

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.tripArray.count == 0)
        return nil;
    
    NSArray *tArray = [self.agencySplitModel objectForKey:self.allAgencyNames[section]];
    
    //Return nil if key is same as object. It is supposed to be a trip array
    if ((tArray == nil) ||([tArray isEqual:self.allAgencyNames[section]])) {
        return nil;
    }
    
    return self.allAgencyNames[section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Retrieve trips for each agency in an array
    NSArray *trip = self.agencySplitModel[self.allAgencyNames[indexPath.section]];
    
    
    //If no trips were created, key is same as object
    if(![trip isEqual:self.allAgencyNames[indexPath.section]])
    {
        //Retrieve each trip for each cell
        self.contactdb = [trip objectAtIndex:indexPath.row];
        
        NSString *cellText = [NSString stringWithFormat:@"%@-%@", [self.contactdb valueForKey:@"fromStation"], [self.contactdb valueForKey:@"toStation"]];
        [cell.textLabel setText:[cellText lowercaseString]];
        
        
        //Below code checks for the default trip id, and sets the checkmark appropriately.
        //Gets the object ID that uniquely identifies a row in table - Trips
        NSManagedObjectID *tripurl = [self.contactdb objectID];
        NSURL *objecturl = [tripurl URIRepresentation];
        NSString *retrievedObjectUrlString = [objecturl absoluteString];

    
        //Trip Detail disclosure
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
        //Set font size, color and type
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0];
        cell.textLabel.textColor = [UIColor blackColor];
    
        if(![retrievedObjectUrlString compare:savedDefaultTripID])
        {
            cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:19.0];
            cell.textLabel.textColor = [UIColor brownColor];
        }
    }
    
    return cell;
}


-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    
    TripDetailViewController *destViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"TripDetailViewController"];
    
    NSArray *trip = self.agencySplitModel[self.allAgencyNames[indexPath.section]];
    
    NSManagedObject *selectedDevice = [trip objectAtIndex:indexPath.row];
    destViewController.contactdb = selectedDevice;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:destViewController];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navController animated:YES completion:nil];
    
}


//#pragma mark - Navigation
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTimerSegue"])
    {
        
        NSArray *trip = self.agencySplitModel[self.allAgencyNames[[[self.tableView indexPathForSelectedRow] section]]];
        //NSLog(@"section - %d, row - %d", [[self.tableView indexPathForSelectedRow] section], [[self.tableView indexPathForSelectedRow] row]);
        
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
        //Get the objectid of the trip that should be deleted.
        NSString *key =self.allAgencyNames[indexPath.section];
        
        NSMutableArray *trip = self.agencySplitModel[key];
        
        NSManagedObject *selectedTrip = [trip objectAtIndex:indexPath.row];
        
        //Delete object from database
        [self.managedObjectContext deleteObject:selectedTrip];
        
        NSError *error = nil;
        if(![self.managedObjectContext save:&error])
        {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Delete the row from the data source
        //From self.tripArray
        [self.tripArray removeObject:selectedTrip];
        //From Dictionary
        [trip removeObjectAtIndex:indexPath.row];
        
        //Remove the section if there are no associated trips for an agency
        if (trip.count == 0)
        {
            [self.agencySplitModel removeObjectForKey:key];
        }
        else
        {
            //Replace the trip array as object in dictionary after deletion
            [self.agencySplitModel setObject:trip forKey:key];
        }
        //Delete the trip ID from UserTable if the trip is a default Trip
        [self.getDataHelper deleteUserData:@"defaultTripID"];
        //Delete row from table view
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadData];
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
