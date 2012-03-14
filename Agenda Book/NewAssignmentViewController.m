
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
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.assignmentField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel:(id)sender
{
	[self.delegate addAssignmentViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    if ([self.assignmentField hasText]) {
        Assignment *assignment = [[Assignment alloc] init];
        assignment.assignmentText = self.assignmentField.text;
        [self.delegate addAssignmentViewController:self didAddAssignment:assignment];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not fill in the teacher or select a subject" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

@end
