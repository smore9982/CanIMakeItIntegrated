//
//  MyTripViewController.m
//  CanIMakeIt
//
//  Created by YOGESH PADMAN on 3/1/14.
//  Copyright (c) 2014 Dakshayani Padman. All rights reserved.
//

#import "MyTripViewController.h"

@interface MyTripViewController ()

@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSArray *pickHour;
@property (strong, nonatomic) NSArray *pickMinute;
@property (strong, nonatomic) NSArray *pickMeridian;

@end

@implementation MyTripViewController

@synthesize contactdb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.pickHour = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12"];
    self.pickMinute = @[@"00", @"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09",
                        @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19",
                        @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29",
                        @"30", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", @"39",
                        @"40", @"41", @"42", @"43", @"44", @"45", @"46", @"47", @"48", @"49",
                        @"50", @"51", @"52", @"53", @"54", @"55", @"56", @"57", @"58", @"59"];
    self.pickMeridian = @[@"AM", @"PM"];
    
    
    
    int phour = 0;
    int pminute = 0;
    int pmeridian = 0;
    
    if(self.contactdb)
    {
        [self.fromStation setText:[self.contactdb valueForKey:@"fromStation"]];
        [self.toStation setText:[self.contactdb valueForKey:@"toStation"]];
        [self.tripTime setText:[self.contactdb valueForKey:@"tripTime"]];
        
        //Saves the time from database to a string.
        self.startTime = [self.contactdb valueForKey:@"startTime"];
        
        //Splits the string - get hour, minute, meridiem
        NSArray *hourMin = [self.startTime componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@": "]];
        
        phour = (int)[hourMin[0] intValue];
        pminute = (int)[hourMin[1] intValue];
        pmeridian = 1;
        
        if([[hourMin objectAtIndex:2] isEqualToString:@"AM"])
            pmeridian = 0;
        else
        {
            pmeridian = 1;
        }
    }
    
    
    //UIPicker for Start Time settings
    [self.startTimePicker setDataSource:self];
    [self.startTimePicker setDelegate:self];
    self.startTimePicker.showsSelectionIndicator = YES;
    
    //Preselect the rows to be displayed in PickerView
    [self.startTimePicker selectRow:phour-1 inComponent:0 animated:YES];
    [self.startTimePicker selectRow:pminute inComponent:1 animated:YES];
    [self.startTimePicker selectRow:pmeridian inComponent:2 animated:YES];
    
    [self.view addSubview:self.startTimePicker];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //if (sender != self.saveTripButton) return;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (self.contactdb)
    {
        //Update existing device
        [self.contactdb setValue:self.fromStation.text forKey:@"fromStation"];
        [self.contactdb setValue:self.toStation.text forKey:@"toStation"];
        [self.contactdb setValue:self.startTime forKey:@"startTime"];
        [self.contactdb setValue:self.tripTime.text forKey:@"tripTime"];
    }
    else
    {
        //Create new device
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Trips" inManagedObjectContext:context];
        [newDevice setValue:self.fromStation.text forKey:@"fromStation"];
        [newDevice setValue:self.toStation.text forKey:@"toStation"];
        [newDevice setValue:self.startTime forKey:@"startTime"];
        [newDevice setValue:self.tripTime.text forKey:@"tripTime"];
    }
    
    NSError *error = nil;
    //Save the object to persistent store
    if(![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}


-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark -
#pragma mark PickerView DataSource

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [self.pickHour count];
    }
    else if(component == 1)
    {
        return [self.pickMinute count];
    }
    else
    {
        return [self.pickMeridian count];
    }
    
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
        return [self.pickHour objectAtIndex:row];
    else if(component == 1)
        return [self.pickMinute objectAtIndex:row];
    else
        return [self.pickMeridian objectAtIndex:row];
    
}

#pragma mark -
#pragma mark PickerView Delegate

-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row - %i", row);
    
    NSInteger firstComponentRow = [self.startTimePicker selectedRowInComponent:0];
    NSInteger secondComponentRow = [self.startTimePicker selectedRowInComponent:1];
    NSInteger thirdComponentRow = [self.startTimePicker selectedRowInComponent:2];
    
    self.startTime = [NSString stringWithFormat:@"%@:%@ %@", self.pickHour[firstComponentRow],self.pickMinute[secondComponentRow], self.pickMeridian[thirdComponentRow]];
    
}

@end
