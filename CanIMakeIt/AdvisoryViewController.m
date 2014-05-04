#import "AdvisoryViewController.h"

@interface AdvisoryViewController ()
@property NSString* section1;
@property NSString* section2;
@property NSMutableDictionary* advisoryDict;
@property NSArray* advisoryKeys;

@end

@implementation AdvisoryViewController
@synthesize advisoryTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithRed:0.226394 green:0.696649 blue:1.0 alpha:1.0];
    
	[self registerForNotifications];
    self.dataHelper = [[DataHelper alloc]init];
    [self.dataHelper getAdvisories:^(NSMutableDictionary* advisoryDict){
        self.advisoryDict = advisoryDict;
        self.advisoryKeys = [self.advisoryDict allKeys];
        [self.advisoryTable reloadData];
    }];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//Implement UIDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.advisoryKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString* key = [self.advisoryKeys objectAtIndex:section];
    NSArray* advisoryArray = [self.advisoryDict valueForKey:key];
    return [advisoryArray count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString* key = [self.advisoryKeys objectAtIndex:section];
    return key;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
        cell.backgroundColor = [UIColor colorWithRed: 0.750212 green: 1.000000 blue: 0.623615 alpha:1.0];
    }
    
    NSString* key = [self.advisoryKeys objectAtIndex:indexPath.section];
    NSArray* advisoryArray = [self.advisoryDict valueForKey:key];
    AdvisoryModel* model = [advisoryArray objectAtIndex:indexPath.row];
    NSString* text =model.advisoryText;
    cell.textLabel.text = text;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath    {
    NSString* key = [self.advisoryKeys objectAtIndex:indexPath.section];
    NSArray* advisoryArray = [self.advisoryDict valueForKey:key];
    AdvisoryModel* model = [advisoryArray objectAtIndex:indexPath.row];
    NSString* text =model.advisoryText;
    
    // set a font size
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    
    // get a constraint size - not sure how it works
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    
    // calculate a label size - takes parameters including the font, a constraint and a specification for line mode
    CGSize labelSize = [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    // give it a little extra height
    return labelSize.height + 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNewAdvisories)
                                                 name:@"UpdateAdvisory" object:nil];
}

-(void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateAdvisory" object:nil];
}

- (void) getNewAdvisories{
    [self.dataHelper getAdvisories:^(NSMutableDictionary* advisoryDict){
        self.advisoryDict = advisoryDict;
        self.advisoryKeys = [self.advisoryDict allKeys];
        [self.advisoryTable reloadData];
    }];
    
    DataHelper* dataHelper = [[DataHelper alloc] init];
    int count = [dataHelper getAdvisoryCountFromLocalDB];
    if(count > 0){
        UITabBar* tabBar = [[self tabBarController] tabBar];
        [[[tabBar items] objectAtIndex:1] setBadgeValue:[NSString stringWithFormat:@"%d",count]];
    }
}

@end
