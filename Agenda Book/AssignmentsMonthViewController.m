
#import "AssignmentsMonthViewController.h"
#import "Functions.h"
#import "CalendarCell.h"
#import "Assignment.h"

@implementation AssignmentsMonthViewController

@synthesize alertView = _alertView;
@synthesize tableView = _tableView;
@synthesize dataDictionary;
@synthesize dateArray;

//static int originy = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataDictionary = [NSMutableDictionary dictionary];
    self.dateArray = [NSMutableArray array];
    
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

- (void)loadAssignments
{
    NSString *path = [[Functions sharedFunctions] assignmentPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        //NSLog(@"dict: '%@'",[dict allKeys]);
        //NSLog(@"count: '%d'",[dict count]);
        for (NSString *teacherKey in [dict allKeys]) {
            NSDictionary *teacherDict = [dict objectForKey:teacherKey];
            for (NSString *assignmentKey in [teacherDict allKeys]) {
                NSArray *assignment = [teacherDict objectForKey:assignmentKey];
                NSLog(@"teacher: '%@'",teacherKey);
                NSLog(@"assignment: '%@'",[assignment objectAtIndex:0]);
                NSLog(@"complete: '%@'",[[assignment objectAtIndex:1] boolValue] ? @"YES" : @"NO");
                NSLog(@"due: '%@'",[[assignment objectAtIndex:2] description]);
            }
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.monthView reload];
    
    [self loadAssignments];
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

- (void)viewWillDisappear:(BOOL)animated
{
    //[self.monthView removeFromSuperview];
}

- (IBAction)goToToday:(id)sender
{
    //[_calendar selectDate:[NSDate date]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (void)after
{
    [self.alertView.progressBar setProgress:1 animated:YES];
}

- (void)after2
{
    [self.alertView hide];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* self.alertView.progressBar.progress = 0;
    [self.alertView show];
    [self performSelector:@selector(after) withObject:nil afterDelay:2];
    [self performSelector:@selector(after2) withObject:nil afterDelay:3]; */
    CalendarCell *tableCell = (CalendarCell *)[tableView dequeueReusableCellWithIdentifier:@"CalendarCell"];
    
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CalendarCell" owner:nil options:nil];
    
    for(id currentObject in topLevelObjects)
    {
        if([currentObject isKindOfClass:[CalendarCell class]])
        {
            tableCell = (CalendarCell *)currentObject;
            break;
        }
    }
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Functions sharedFunctions] colorForComplete:TRUE];
    tableCell.backgroundView = backgroundView;
    tableCell.assignment.text = @"Test";
    tableCell.due.text = @"Due: 00/01/0000";
    
    return tableCell;
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
    //NSLog(@"Selected date: '%@'",[date description]);
    /* self.alertView.progressBar.progress = 0;
    [self.alertView show];
    [self performSelector:@selector(after) withObject:nil afterDelay:2];
    [self performSelector:@selector(after2) withObject:nil afterDelay:3]; */
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)month animated:(BOOL)animated
{
    [self updateOffset];
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
    
    TKDateInformation info = [d dateInformationWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSArray *data = [NSArray arrayWithObjects:[NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]], nil];
    NSLog(@"date: '%@'",[NSDate dateFromDateInformation:info timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]);
	
	// for each date between start date and end date check if they exist in the data array
	while (YES) {
		// Is the date beyond the last date? If so, exit the loop.
		// NSOrderedDescending = the left value is greater than the right
		if ([d compare:lastDate] == NSOrderedDescending) {
			break;
		}
		
		// If the date is in the data array, add it to the marks array, else don't
		if ([data containsObject:[d description]]) {
			[marks addObject:[NSNumber numberWithBool:YES]];
		} else {
			[marks addObject:[NSNumber numberWithBool:NO]];
		}
		
		// Increment day using offset components (ie, 1 day in this instance)
		d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
	}
    return [NSArray arrayWithArray:marks];
}

- (TKProgressAlertView *)alertView{
	if(_alertView == nil){
		_alertView = [[TKProgressAlertView alloc] initWithProgressTitle:@"Loading important stuff!"];
	}
	return _alertView;
}

@end
