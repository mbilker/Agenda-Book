
#import "NewAssignmentViewController.h"
#import "Assignment.h"

@implementation NewAssignmentViewController

@synthesize delegate;
@synthesize assignmentField;

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
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.assignmentField becomeFirstResponder];
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
        [self.delegate addAssignmentViewController:self didAddAssignment:assignment];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not enter an assignment" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //NSLog(@"Done button hit");
    [self checkDone];
    return NO;
}

- (IBAction)cancel:(id)sender
{
	[self.delegate addAssignmentViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    [self checkDone];
}

@end
