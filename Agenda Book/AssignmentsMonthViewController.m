
#import "AssignmentsMonthViewController.h"
#import "Functions.h"
#import "CalendarCell.h"
#import "Assignment.h"

@implementation AssignmentsMonthViewController

@synthesize alertView = _alertView;
@synthesize tableView = _tableView;
@synthesize dataDictionary;
@synthesize dateArray;
//@synthesize dateFormatter;

@synthesize managedObjectContext;

//static int originy = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init AssignmentsMonthViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc AssignmentsMonthViewController");
}

/* - (void)loadAssignments
{
    self.alertView.progressBar.progress = 0;
    [self.alertView show];
    NSString *path = [[Functions sharedFunctions] assignmentPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        _loaded = TRUE;
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        //NSLog(@"dict: '%@'",[dict allKeys]);
        //NSLog(@"count: '%d'",[dict count]);
        for (NSString *teacherKey in [dict allKeys]) {
            NSDictionary *teacherDict = [dict objectForKey:teacherKey];
            for (NSString *assignmentKey in [teacherDict allKeys]) {
                NSArray *assignmentArray = [teacherDict objectForKey:assignmentKey];
                //NSLog(@"teacher: '%@'",teacherKey);
                //NSLog(@"assignment: '%@'",[assignmentArray objectAtIndex:0]);
                //NSLog(@"complete: '%@'",[[assignmentArray objectAtIndex:1] boolValue] ? @"YES" : @"NO");
                //NSLog(@"due: '%@'",[[assignmentArray objectAtIndex:2] description]);
                DateAssignment *assignment = [[DateAssignment alloc] init];
                assignment.assignmentText = [assignmentArray objectAtIndex:0];
                assignment.complete = [[assignmentArray objectAtIndex:1] boolValue];
                assignment.teacher = teacherKey;
                NSLog(@"%@",assignment);
                NSMutableArray *array;
                if ([[self.dataDictionary allKeys] containsObject:[self.dateFormatter stringFromDate:[assignmentArray objectAtIndex:2]]]) {
                    array = [self.dataDictionary objectForKey:[self.dateFormatter stringFromDate:[assignmentArray objectAtIndex:2]]];
                } else {
                    array = [NSMutableArray array];
                }
                [array addObject:assignment];
                [self.dataDictionary setObject:array forKey:[self.dateFormatter stringFromDate:[assignmentArray objectAtIndex:2]]];
                [self.dateArray addObject:[self.dateFormatter stringFromDate:[assignmentArray objectAtIndex:2]]];
            }
        }
        NSLog(@"all: '%@'",self.dataDictionary);
        NSLog(@"all: '%@'",self.dateArray);
    }
} */

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.dateFormatter = [[NSDateFormatter alloc] init];
    //[self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    //[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.dateArray = [NSMutableArray array];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (Assignment *assignment in fetchedObjects) {
        NSMutableArray *array;
        if ([[self.dataDictionary allKeys] containsObject:[[Functions sharedFunctions] dateWithOutTime:assignment.dueDate]]) {
            array = [self.dataDictionary objectForKey:[[Functions sharedFunctions] dateWithOutTime:assignment.dueDate]];
        } else {
            array = [NSMutableArray array];
        }
        [array addObject:assignment];
        [dictionary setObject:array forKey:[[Functions sharedFunctions] dateWithOutTime:assignment.dueDate]];
        if (![self.dateArray containsObject:[[Functions sharedFunctions] dateWithOutTime:assignment.dueDate]])
            [self.dateArray addObject:[[Functions sharedFunctions] dateWithOutTime:assignment.dueDate]];
    }
    self.dataDictionary = [NSDictionary dictionaryWithDictionary:dictionary];
    //[self loadAssignments];
    
    [self.monthView reload];
    self.tableView.backgroundColor = [UIColor whiteColor];
	
	float y,height;
	y = self.monthView.frame.origin.y + self.monthView.frame.size.height;
	height = self.view.frame.size.height - y;
    
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, self.view.bounds.size.width, height) style:UITableViewStylePlain];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:_tableView];
	[self.view sendSubviewToBack:_tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.monthView selectDate:[NSDate date]];
    [self.tableView reloadData];
}

- (void)updateOffset
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.1];
    
	
	float y = self.monthView.frame.origin.y + self.monthView.frame.size.height;
	self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, y, self.tableView.frame.size.width, self.view.frame.size.height - y);
	
	[UIView commitAnimations];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self updateOffset];
}

- (IBAction)goToToday:(id)sender
{
    [self.monthView selectDate:[NSDate date]];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *ar = [self.dataDictionary objectForKey:[[Functions sharedFunctions] dateWithOutTime:[self.monthView dateSelected]]];
	if(ar == nil) return 0;
	return [ar count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCell *cell = (CalendarCell *)[tableView dequeueReusableCellWithIdentifier:@"CalendarCell"];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CalendarCell" owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[CalendarCell class]])
        {
            cell = (CalendarCell *)currentObject;
            break;
        }
    }
    
    NSArray *assignmentArray = [self.dataDictionary objectForKey:[[Functions sharedFunctions] dateWithOutTime:[self.monthView dateSelected]]];
    Assignment *assignment = [assignmentArray objectAtIndex:indexPath.row];
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Functions sharedFunctions] colorForComplete:assignment.complete];
    cell.backgroundView = backgroundView;
    cell.assignment.text = assignment.assignmentText;
    cell.teacher.text = assignment.teacher;
    //tableCell.due.text = [NSString stringWithFormat:@"Due: %@",[self.dateFormatter stringFromDate:assignment.dueDate]];
    /* self.alertView.progressBar.progress = 0;
    [self.alertView show];
    [self performSelector:@selector(after) withObject:nil afterDelay:2];
    [self performSelector:@selector(after2) withObject:nil afterDelay:3]; */
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Functions sharedFunctions] shouldAutorotate:interfaceOrientation];
}

#pragma mark - TKCalendarMonthViewDelegate

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)date
{
    NSLog(@"Selected date: '%@'",[date description]);
    [self.tableView reloadData];
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated
{
    [self updateOffset];
    [self.tableView reloadData];
}

- (NSArray *)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate
{
    NSLog(@"Called marks");
    
    NSMutableArray *marks = [NSMutableArray array];
    
    // Initialise calendar to current type and set the timezone to never have daylight saving
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	// Construct DateComponents based on startDate so the iterating date can be created.
	// Its massively important to do this assigning via the NSCalendar and NSDateComponents because of daylight saving has been removed 
	// with the timezone that was set above. If you just used "startDate" directly (ie, NSDate *date = startDate;) as the first 
	// iterating date then times would go up and down based on daylight savings.
	NSDateComponents *comp = [cal components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) fromDate:startDate];
	NSDate *d = [cal dateFromComponents:comp];
	
	// Init offset components to increment days in the loop by one each time
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:1];
    
    //TKDateInformation info = [d dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    //NSArray *data = [NSArray arrayWithObjects:[NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]], nil];
	
	// for each date between start date and end date check if they exist in the data array
    //if (!_loaded) [self loadAssignments];
	while (YES) {
		// Is the date beyond the last date? If so, exit the loop.
		// NSOrderedDescending = the left value is greater than the right
		if ([d compare:lastDate] == NSOrderedDescending) {
			break;
		}
		
		// If the date is in the data array, add it to the marks array, else don't
		if ([self.dateArray containsObject:[[Functions sharedFunctions] dateWithOutTime:d]]) {
			[marks addObject:[NSNumber numberWithBool:YES]];
		} else {
			[marks addObject:[NSNumber numberWithBool:NO]];
		}
		
		// Increment day using offset components (ie, 1 day in this instance)
		d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
	}
    [self.alertView.progressBar setProgress:1 animated:YES];
    [self.alertView hide];
    return [NSArray arrayWithArray:marks];
}

- (TKProgressAlertView *)alertView {
	if(_alertView == nil){
		_alertView = [[TKProgressAlertView alloc] initWithProgressTitle:@"Loading important stuff!"];
	}
	return _alertView;
}

@end
