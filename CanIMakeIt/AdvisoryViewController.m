#import "AdvisoryViewController.h"

@interface AdvisoryViewController ()
@property NSString* section1;
@property NSString* section2;


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
	NSLog(@"Loading advisory");
    _items = [[NSArray alloc] initWithObjects:@"There was an accidnet on this line. Trip is delayed by 10 minutes. HELLo heloajfinf hiawdoia awdiaowdjoiaj", nil];
    _items1 = [[NSArray alloc] initWithObjects:@"There was another accidnet on this line. Trip is delayed by 10 minutes. HELLo heloajfinf hiawdoia awdiaowdjoiajjia dhadjowo fqifjqoijfiqof qfksjlkfjoiqjr dfqkncdnioq fkwjfioqjiofqfq fqjkfjiovnjkdfjoiqf djioqwjioqfd",@"This is a seconde line", nil];
    _section1 = @"LIRR";
    _section2 = @"NJT";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//Implement UIDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    // Usually the number of items in your array (the one that holds your list)
    if(section==0){
        return [_items count];
    }else{
        return [_items1 count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return _section1;
    else
        return _section2;
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
    }
    
    // Configure the cell... setting the text of our cell's label
    if(indexPath.section == 0){
        cell.textLabel.text = [_items objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = [_items1 objectAtIndex:indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath    {
    NSString* text;
    if(indexPath.section == 0 ){
        text = [_items objectAtIndex:indexPath.row];
    }else if (indexPath.section == 1){
        text = [_items1 objectAtIndex:indexPath.row];
    }
    
    if(text == nil || [text length] <=0){
        return 100;
    }
    
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

@end
