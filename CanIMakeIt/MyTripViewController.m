//
//  MyTripViewController.m
//  CanIMakeIt
//
//  Created by DAKSHAYANI PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "MyTripViewController.h"
#import "DataHelper.h"
#import "Utility.h"

@interface MyTripViewController ()

@property (strong, nonatomic) NSMutableArray *stopNames;
@property (strong, nonatomic) NSMutableArray *transferStops;
@property (strong, nonatomic) NSArray *pickHour;
@property (strong, nonatomic) NSArray *pickMinute;
@property (strong, nonatomic) NSArray *pickMeridiem;
@property (strong, nonatomic) NSArray *tripHour;
@property DataHelper *stopDataHelper;
@property BOOL textFieldTouch1;
@property BOOL textFieldTouch2;
@property BOOL textFieldTouch3;

@property (nonatomic, retain) UITableView *stationTableViewOne;
@property (nonatomic, retain) UITableView *stationTableViewTwo;
@property (nonatomic, retain) UITableView *transferStationTable;

@end

@implementation MyTripViewController

@synthesize contactdb;
@synthesize currentPicker;
@synthesize currentTextField;
@synthesize stationTableViewOne;
@synthesize stationTableViewTwo;
@synthesize transferStationTable;
@synthesize agencyName;
@synthesize agencyId;
@synthesize agencyModel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    
    return context;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.226394 green:0.696649 blue:1.0 alpha:1.0];
	// Do any additional setup after loading the view.
    
    //Initialize DataHelper
    self.stopDataHelper = [[DataHelper alloc] init];
    self.agencyModel = [self.stopDataHelper getAgencyData];
    
    //Display Data in TextFields if on EDIT MODE
    if(self.contactdb)
    {
        [self.fromStation setText:[self.contactdb valueForKey:@"fromStation"]];
        [self.toStation setText:[self.contactdb valueForKey:@"toStation"]];
        [self.transferStation setText:[self.contactdb valueForKey:@"transferStation"]];
        
        NSString *tripMin = [Utility convertSecondsToTripTimeStr:[self.contactdb valueForKey:@"tripTime"]];
        [self.tripTime setText:tripMin];
        
        
        NSString *timeMerd = [Utility convertTimeto12Hour:[self.contactdb valueForKey:@"startTime"]];
        [self.startTime setText:timeMerd];
        
        //Get Agency Name in Edit mode from agency ID stored in table
        self.agencyId = [self.contactdb valueForKey:@"agencyId" ];
        self.agencyName = self.agencyModel[self.agencyId];
    }
    else
    {
        //ON ADD MODE
        //Get Agency Id for a selected agency name from dictionary
        self.agencyId = [self.agencyModel allKeysForObject:self.agencyName][0];
    }
    
    //Display Agency Name
    [self.agencyLabel setText:[NSString stringWithFormat:@"* %@",self.agencyName]];
    
    
    //Getting all Initial Data that will be displayed to User for selection in EITHER MODES
    self.stopNames = [[NSMutableArray alloc] initWithArray:[[self.stopDataHelper getStopsForAgency:self.agencyId] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.stopNames insertObject:@"N/A" atIndex:0];
    
    //Get Transfer Stop Names
    self.transferStops = [[NSMutableArray alloc] initWithArray:[[self.stopDataHelper getTransferStopsForAgency:self.agencyId] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [self.transferStops insertObject:@"N/A" atIndex:0];
    
    
    //Set Time - hour, min, seconds for Picker View
    self.pickHour = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
    self.pickMinute = @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09",
                        @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
                        @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
                        @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
                        @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
                        @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"];
    self.pickMeridiem = @[@"AM", @"PM"];
    self.tripHour = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
    
    
    //Creating Table View for Departure Station Names
    self.stationTableViewOne = [[UITableView alloc] initWithFrame:CGRectMake(20, 115, 289, 320) style:UITableViewStyleGrouped];
    self.stationTableViewOne.dataSource = self;
    self.stationTableViewOne.delegate = self;
    self.stationTableViewOne.tag = 1;
    self.stationTableViewOne.scrollEnabled = YES;
    self.stationTableViewOne.backgroundColor = [UIColor lightGrayColor];
    
    //Creating Table View for Destination Station Names
    self.stationTableViewTwo = [[UITableView alloc] initWithFrame:CGRectMake(20, 155, 289, 320) style:UITableViewStyleGrouped];
    self.stationTableViewTwo.dataSource = self;
    self.stationTableViewTwo.delegate = self;
    self.stationTableViewTwo.tag = 2;
    self.stationTableViewTwo.scrollEnabled = YES;
    self.stationTableViewTwo.backgroundColor = [UIColor lightGrayColor];
    
    
    //Create Table View for Transfer Stations
    self.transferStationTable = [[UITableView alloc] initWithFrame:CGRectMake(20, 190, 289, 320) style:UITableViewStyleGrouped];
    self.transferStationTable.dataSource = self;
    self.transferStationTable.delegate = self;
    self.transferStationTable.tag = 3;
    self.transferStationTable.scrollEnabled = YES;
    self.transferStationTable.backgroundColor = [UIColor lightGrayColor];
    
    
    //Set the placeholder text, and its font color
    self.fromStation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Departure Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.toStation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Destination Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.transferStation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Transfer Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.tripTime.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Approx. Time to Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    self.startTime.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Time to Start Timer" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    //Sets the Boolean values to false for textfields (To Toggle between table displays)
    self.textFieldTouch1 = false;
    self.textFieldTouch2 = false;
    self.textFieldTouch3 = false;
    
    
    //Hide ProgressIcon and Picker View
    [self.progressIcon setHidden:YES];
    [self.currentPicker setHidden:YES];
}

-(UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    //Set current textField to identify the textfield type - fromStation, toStation, departTime, startTime
    self.currentTextField = textField;
    
    
    if(self.currentTextField.tag == 1)
    {
        self.textFieldTouch1 = !self.textFieldTouch1;
        [self.currentTextField resignFirstResponder];
        self.currentTextField.text = nil;
        if (self.textFieldTouch1)
        {
            self.currentTextField.placeholder = nil;
            [self.view addSubview:self.stationTableViewOne];
            [self.stationTableViewOne reloadData];
        }
        else
        {
            self.currentTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Departure Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            [self.stationTableViewOne removeFromSuperview];
        }
        
    }
    else if(self.currentTextField.tag == 2)
    {
        self.textFieldTouch2 = !self.textFieldTouch2;
        [self.currentTextField resignFirstResponder];
        self.currentTextField.text = nil;
        if (self.textFieldTouch2)
        {
            self.currentTextField.placeholder = nil;
            [self.view addSubview:self.stationTableViewTwo];
            [self.stationTableViewTwo reloadData];
        }
        else
        {
            self.currentTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Destination Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            [self.stationTableViewTwo removeFromSuperview];
        }
        
    }
    else if(self.currentTextField.tag == 3)
    {
        self.textFieldTouch3 = !self.textFieldTouch3;
        [self.currentTextField resignFirstResponder];
        self.currentTextField.text = nil;
        if (self.textFieldTouch3)
        {
            
            self.currentTextField.placeholder = nil;
            [self.view addSubview:self.transferStationTable];
            [self.transferStationTable reloadData];
        }
        else
        {
            self.currentTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Transfer Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            [self.transferStationTable removeFromSuperview];
            
            
        }
        
    }
    else
    {
        //remove placeholder text
        self.currentTextField.placeholder = nil;
        
        //Show UIPicker
        [self.currentPicker setHidden:NO];
        
        self.currentPicker.tag = self.currentTextField.tag;
    
        [self.currentPicker setDataSource:self];
        [self.currentPicker setDelegate:self];
        self.currentPicker.showsSelectionIndicator = YES;
    
    
        //Pre-Select Rows
        if (self.currentPicker.tag == 4)
        {
            [self.currentPicker selectRow:0 inComponent:0 animated:YES];
            [self.currentPicker selectRow:0 inComponent:1 animated:YES];
        }
        else if (self.currentPicker.tag == 5)
        {
            [self.currentPicker selectRow:0 inComponent:0 animated:YES];
            [self.currentPicker selectRow:0 inComponent:1 animated:YES];
            [self.currentPicker selectRow:0 inComponent:2 animated:YES];
        }
    
        self.currentTextField.inputView = self.currentPicker;
    
        [self.currentPicker reloadAllComponents];
    }
    
    
    return NO;
}



#pragma mark -
#pragma mark TableView DataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 3)
        return self.transferStops.count;
    else
        return self.stopNames.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"stationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    
    if (tableView.tag == 3)
        [cell.textLabel setText:[self.transferStops objectAtIndex:indexPath.row]];
    else
        [cell.textLabel setText:[self.stopNames objectAtIndex:indexPath.row]];
    
    
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    return cell;
}


#pragma mark -
#pragma mark TableView Delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(tableView.tag == 1)
    {
        [self.fromStation setText:cell.textLabel.text];
        self.textFieldTouch1 = false;
        [self.stationTableViewOne removeFromSuperview];
    }
    else if(tableView.tag == 2)
    {
        [self.toStation setText:cell.textLabel.text];
        self.textFieldTouch2 = false;
        [self.stationTableViewTwo removeFromSuperview];

    }
    else if(tableView.tag == 3)
    {
        [self.transferStation setText:cell.textLabel.text];
        self.textFieldTouch3 = false;
        [self.transferStationTable removeFromSuperview];
    }
    
}

#pragma mark -
#pragma mark PickerView DataSource

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger numOfComponents = 1;
    
    if (pickerView.tag == 4)
        numOfComponents = 2;
    else if(pickerView.tag == 5)
        numOfComponents = 3;
    
    
    return numOfComponents;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numOfRows = 1;
    
    
    if(pickerView.tag == 4)
    {
        if (component == 0)
            numOfRows = [self.tripHour count];
        else
            numOfRows = [self.pickMinute count];
    }
    else if (pickerView.tag == 5)
    {
        if (component == 0)
            numOfRows = [self.pickHour count];
        else if (component == 1)
            numOfRows = [self.pickMinute count];
        else
            numOfRows = [self.pickMeridiem count];
    }
    
    
    return numOfRows;
    
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *showTitle = [[NSString alloc] init];
    
    if (pickerView.tag == 4)
    {
        if (component == 0)
            showTitle = [self.tripHour objectAtIndex:row];
        else
            showTitle = [self.pickMinute objectAtIndex:row];
    }
    else if(pickerView.tag == 5)
    {
        if (component == 0)
            showTitle = [self.pickHour objectAtIndex:row];
        else if (component == 1)
            showTitle = [self.pickMinute objectAtIndex:row];
        else
            showTitle = [self.pickMeridiem objectAtIndex:row];
    }
    
    
    return showTitle;
    
}

#pragma mark -
#pragma mark PickerView Delegate

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView.tag == 4)
    {
        NSInteger firstRow = [pickerView selectedRowInComponent:0];
        NSInteger secondRow = [pickerView selectedRowInComponent:1];
        
        
        [self.currentTextField setText:[NSString stringWithFormat:@"%@ hour %@ minutes", [self.tripHour objectAtIndex:firstRow], [self.pickMinute objectAtIndex:secondRow]]];
    }
    else if (pickerView.tag == 5)
    {
        NSInteger firstRow = [pickerView selectedRowInComponent:0];
        NSInteger secondRow = [pickerView selectedRowInComponent:1];
        NSInteger thirdRow = [pickerView selectedRowInComponent:2];
        
        [self.currentTextField setText:[NSString stringWithFormat:@"%@:%@ %@", [self.pickHour objectAtIndex:firstRow],[self.pickMinute objectAtIndex:secondRow],[self.pickMeridiem objectAtIndex:thirdRow]]];
    }

    
}

//Method to dismiss table subview, hide UiPicker when touched outside textfields
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    UITouch *touch = [touches anyObject];
    if(![touch.view isKindOfClass:[MyTripViewController class]])
    {
        if([self.stationTableViewOne isDescendantOfView:[self view]])
            [self.stationTableViewOne removeFromSuperview];
            
        if([self.stationTableViewTwo isDescendantOfView:[self view]])
            [self.stationTableViewTwo removeFromSuperview];
        
        if([self.transferStationTable isDescendantOfView:[self view]])
            [self.transferStationTable removeFromSuperview];
            
        if(![self.currentPicker isHidden])
            [self.currentPicker setHidden:YES];
        
        if (self.fromStation.placeholder == nil)
        {
            self.fromStation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Departure Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            self.textFieldTouch1 = false;
        }
        else if (self.toStation.placeholder == nil)
        {
            self.toStation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Destination Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            self.textFieldTouch2 = false;
        }
        else if (self.transferStation.placeholder == nil)
        {
            self.transferStation.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Transfer Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            self.textFieldTouch3 = false;
        }
        else if (self.tripTime.placeholder == nil)
            self.tripTime.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Approx. Time to Station" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        else if (self.startTime.placeholder == nil)
            self.startTime.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Time to Start Timer" attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    //Hide the picker
    if(![self.currentPicker isHidden])
        [self.currentPicker setHidden:YES];
    
    if(sender == self.saveTripButton)
    {
        
        //Check for Empty textfields, and alert User.
        if ([self.fromStation.text length] == 0)
        {
            UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Empty TextField" message:@"From Station must be selected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertUser show];
            
            return NO;
        }
        else if ([self.toStation.text length] == 0)
        {
            UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Empty TextField" message:@"To Station must be selected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertUser show];
            [alertUser reloadInputViews];
            
            return NO;
        }
        else if ([self.tripTime.text length] == 0)
        {
            UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Empty TextField" message:@"Trip Time must be selected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertUser show];
            [alertUser reloadInputViews];
            
            return NO;
        }
        else if([self.startTime.text length] == 0)
        {
            UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Empty TextField" message:@"Start Time must be selected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertUser show];
            [alertUser reloadInputViews];
            
            return NO;
        }
        else if([self.transferStation.text length] == 0)
        {
            [self.transferStation setText:@"N/A"];
        }
        
        //Check if from-station is not same as the to-station
        if([self.fromStation.text isEqualToString:self.toStation.text])
        {
            UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Incorrect Data" message:@"Departure and Destination Stations cannot be same!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            self.toStation.text = nil;
            [alertUser show];
            [alertUser reloadInputViews];
            
            return NO;
        }
        
        //Load the departure times for the departure and destination station
        StopModel *fromStationInfo = [self.stopDataHelper getStopModelWithName:self.fromStation.text];
        StopModel *toStationInfo = [self.stopDataHelper getStopModelWithName:self.toStation.text];
        StopModel *transferStationInfo = [self.stopDataHelper getStopModelWithName:self.transferStation.text];
        
        [self.stopDataHelper saveTripDepartureTimesWithDepartureId:fromStationInfo.stopId DestionstionID:toStationInfo.stopId TransferID :transferStationInfo.stopId
        completion:^(NSString *onComp){
            //Saving Trip Profile to Database
            NSManagedObjectContext *context = [self managedObjectContext];
            
            //Function to convert tripTime to minutes
            NSString *totalMins = [Utility convertTripTimeToSeconds:self.tripTime.text];
            
            //Function to convert meridiem to 24 hour
            NSString *timein24 = [Utility convertTimeto24Hour:self.startTime.text];
            
            
            if (self.contactdb)
            {
                [self.contactdb setValue:self.fromStation.text forKey:@"fromStation"];
                [self.contactdb setValue:self.toStation.text forKey:@"toStation"];
                [self.contactdb setValue:self.transferStation.text forKey:@"transferStation"];
                [self.contactdb setValue:timein24 forKey:@"startTime"];
                [self.contactdb setValue:totalMins forKey:@"tripTime"];
                [self.contactdb setValue:[NSDate date] forKey:@"dateAdded"];
            }
            else
            {
                NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Trips" inManagedObjectContext:context];
                [newDevice setValue:self.agencyId forKey:@"agencyId"];
                [newDevice setValue:self.fromStation.text forKey:@"fromStation"];
                [newDevice setValue:self.toStation.text forKey:@"toStation"];
                [newDevice setValue:self.transferStation.text forKey:@"transferStation"];
                [newDevice setValue:timein24 forKey:@"startTime"];
                [newDevice setValue:totalMins forKey:@"tripTime"];
                [newDevice setValue:[NSDate date] forKey:@"dateAdded"];
            }
            NSError *error = nil;
            //Save the object to persistent store
            if(![context save:&error])
            {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            [self.progressIcon setHidden:true];
            [self.progressIcon stopAnimating];
            [self performSegueWithIdentifier:@"saveSegue" sender:self];
            return YES;
        }
        error:^(NSString *onErr)
        {
            NSMutableString* errorString = [[NSMutableString alloc]init];
            
            if(onErr != nil && !([onErr isEqualToString:@""])){
                [errorString setString:onErr];
            }else{
                [errorString setString:@"An error occured trying to save the profile. Please try again"];
            }
         
            UIAlertView *alertUser = [[UIAlertView alloc] initWithTitle:@"Data Load Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertUser show];
            [self.progressIcon setHidden:true];
            [self.progressIcon stopAnimating];
            return NO;
        }];
        [self.progressIcon setHidden:false];
        [self.progressIcon startAnimating];
        
        //Completion Handlers will handle the segue when save is clicked.
        return NO;
    
    }else{
        return YES;
    }
}
@end
