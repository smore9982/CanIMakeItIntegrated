//
//  MyTripViewController.m
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "MyTripViewController.h"
#import "DataHelper.h"
#import "Utility.h"

@interface MyTripViewController ()

@property (strong, nonatomic) NSArray *stopNames;
@property (strong, nonatomic) NSArray *pickHour;
@property (strong, nonatomic) NSArray *pickMinute;
@property (strong, nonatomic) NSArray *pickMeridiem;
@property (strong, nonatomic) NSArray *tripHour;

@end

@implementation MyTripViewController

@synthesize contactdb;
@synthesize currentPicker;
@synthesize currentTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
	// Do any additional setup after loading the view.
    
    //Get Stop Names for agency - LIRR
    //DataHelper *stopDataHelper = [[DataHelper alloc] init];
    //NSArray *stops = [stopDataHelper getStopNames:@"LIRR"];
    
    
    self.stopNames = @[@"Atlantic Terminal", @"Forest Hills", @"Penn Station", @"Long Island City"];
    
    self.pickHour = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
    self.pickMinute = @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09",
                        @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
                        @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
                        @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
                        @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
                        @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"];
    self.pickMeridiem = @[@"AM", @"PM"];
    self.tripHour = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
    
    
    if(self.contactdb)
    {
        [self.fromStation setText:[self.contactdb valueForKey:@"fromStation"]];
        [self.toStation setText:[self.contactdb valueForKey:@"toStation"]];
        
        
        NSString *tripMin = [Utility convertMinutesToTripTimeStr:[self.contactdb valueForKey:@"tripTime"]];
        [self.tripTime setText:tripMin];
        
        
        NSString *timeMerd = [Utility convertTimeto12Hour:[self.contactdb valueForKey:@"startTime"]];
        [self.startTime setText:timeMerd];
    }
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    //Set current textField to identify the textfield type - fromStation, toStation, departTime, startTime
    self.currentTextField = textField;
    
    self.currentPicker.tag = self.currentTextField.tag;
    
    [self.currentPicker setDataSource:self];
    [self.currentPicker setDelegate:self];
    self.currentPicker.showsSelectionIndicator = YES;
    
    
    //Pre-Select Rows
    if (self.currentPicker.tag == 3)
    {
        [self.currentPicker selectRow:0 inComponent:0 animated:YES];
        [self.currentPicker selectRow:0 inComponent:1 animated:YES];
    }
    else if (self.currentPicker.tag == 4)
    {
        [self.currentPicker selectRow:0 inComponent:0 animated:YES];
        [self.currentPicker selectRow:0 inComponent:1 animated:YES];
        [self.currentPicker selectRow:0 inComponent:2 animated:YES];
    }
    else
    {
        [self.currentPicker selectRow:0 inComponent:0 animated:YES];
    }
    
    self.currentTextField.inputView = self.currentPicker;
    
    [self.currentPicker reloadAllComponents];
    
    
    return NO;
}

#pragma mark -
#pragma mark PickerView DataSource

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger numOfComponents = 1;
    
    if (pickerView.tag == 3)
        numOfComponents = 2;
    else if(pickerView.tag == 4)
        numOfComponents = 3;
    else
        numOfComponents =  1;
    
    
    return numOfComponents;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numOfRows = 1;
    
    
    if(pickerView.tag == 3)
    {
        if (component == 0)
            numOfRows = [self.tripHour count];
        else
            numOfRows = [self.pickMinute count];
    }
    else if (pickerView.tag == 4)
    {
        if (component == 0)
            numOfRows = [self.pickHour count];
        else if (component == 1)
            numOfRows = [self.pickMinute count];
        else
            numOfRows = [self.pickMeridiem count];
    }
    else
        numOfRows = [self.stopNames count];
    
    
    return numOfRows;
    
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *showTitle = [[NSString alloc] init];
    
    if (pickerView.tag == 3)
    {
        if (component == 0)
            showTitle = [self.tripHour objectAtIndex:row];
        else
            showTitle = [self.pickMinute objectAtIndex:row];
    }
    else if(pickerView.tag == 4)
    {
        if (component == 0)
            showTitle = [self.pickHour objectAtIndex:row];
        else if (component == 1)
            showTitle = [self.pickMinute objectAtIndex:row];
        else
            showTitle = [self.pickMeridiem objectAtIndex:row];
    }
    else
        showTitle = [self.stopNames objectAtIndex:row];
    
    
    return showTitle;
    
}

#pragma mark -
#pragma mark PickerView Delegate

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (pickerView.tag == 3)
    {
        NSInteger firstRow = [pickerView selectedRowInComponent:0];
        NSInteger secondRow = [pickerView selectedRowInComponent:1];
        
        
        [self.currentTextField setText:[NSString stringWithFormat:@"%@ hour %@ minutes", [self.tripHour objectAtIndex:firstRow], [self.pickMinute objectAtIndex:secondRow]]];
    }
    else if (pickerView.tag == 4)
    {
        NSInteger firstRow = [pickerView selectedRowInComponent:0];
        NSInteger secondRow = [pickerView selectedRowInComponent:1];
        NSInteger thirdRow = [pickerView selectedRowInComponent:2];
        
        [self.currentTextField setText:[NSString stringWithFormat:@"%@:%@ %@", [self.pickHour objectAtIndex:firstRow],[self.pickMinute objectAtIndex:secondRow],[self.pickMeridiem objectAtIndex:thirdRow]]];
    }
    else
    {
        NSInteger firstRow = [pickerView selectedRowInComponent:0];
        
        [self.currentTextField setText:[self.stopNames objectAtIndex:firstRow]];
    }
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.saveTripButton) return;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //Set Functions to alert User about empty textfields.
    
    //Function to alert User that departure station is same as destination station
    
    //Function to convert tripTime to minutes
    NSString *totalMins = [Utility convertTripTimeToMinutes:self.tripTime.text];
    
    
    //Function to convert meridiem to 24 hour
    NSString *timein24 = [Utility convertTimeto24Hour:self.startTime.text];
    
    NSLog(@"24 hour clock-%@", timein24);
    
    if (self.contactdb)
    {
        //Update existing device
        [self.contactdb setValue:self.fromStation.text forKey:@"fromStation"];
        [self.contactdb setValue:self.toStation.text forKey:@"toStation"];
        [self.contactdb setValue:timein24 forKey:@"startTime"];
        [self.contactdb setValue:totalMins forKey:@"tripTime"];
    }
    else
    {
        //Create new device
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Trips" inManagedObjectContext:context];
        [newDevice setValue:self.fromStation.text forKey:@"fromStation"];
        [newDevice setValue:self.toStation.text forKey:@"toStation"];
        [newDevice setValue:timein24 forKey:@"startTime"];
        [newDevice setValue:totalMins forKey:@"tripTime"];
    }
    
    NSError *error = nil;
    //Save the object to persistent store
    if(![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}

@end
