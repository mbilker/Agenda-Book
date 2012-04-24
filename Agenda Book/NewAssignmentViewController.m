
#import "NewAssignmentViewController.h"
#import "Assignment.h"

@implementation NewAssignmentViewController

@synthesize delegate;
@synthesize assignmentField;
@synthesize duePicker;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init NewAssignmentViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc NewAssignmentViewController");
}

- (void)viewDidLoad
{
    self.assignmentField.delegate = self;
    self.duePicker.minimumDate = [NSDate date];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.assignmentField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)checkDone
{
    if ([self.assignmentField hasText]) {
        Assignment *assignment = [[Assignment alloc] init];
        assignment.assignmentText = self.assignmentField.text;
        assignment.complete = FALSE;
        assignment.dueDate = self.duePicker.date;
        [self.delegate addAssignmentViewController:self didAddAssignment:assignment];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not enter an assignment" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //NSLog(@"Done button hit");
    //[self checkDone];
    [theTextField resignFirstResponder];
    return YES;
}

- (IBAction)cancel:(id)sender
{
	[self.delegate addAssignmentViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    NSLog(@"Date picked: %@",self.duePicker.date);
    [self checkDone];
}

/* #pragma mark - UIPickerViewDelegate

- (void)changeDateInLabel:(id)sender{
	//Use NSDateFormatter to write out the date in a friendly format
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:self.duePicker.date]]);
} */

@end
