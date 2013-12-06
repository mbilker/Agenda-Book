
#import "AssignmentDetailsViewController.h"
#import "Utils.h"

@implementation AssignmentDetailsViewController

@synthesize assignmentText;
@synthesize complete;
@synthesize dueDate;
@synthesize assignment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init AssignmentDetailsViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc AssignmentDetailsViewController");
}

- (void)viewDidLoad
{
    self.assignmentText.text = [NSString stringWithFormat:@"Assignment: %@", assignment.assignmentText];
    self.complete.text = [NSString stringWithFormat:@"Complete: %@", assignment.complete ? @"YES" : @"NO"];
    
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateStyle:NSDateFormatterShortStyle];
    self.dueDate.text = [NSString stringWithFormat:@"Due: %@",[date stringFromDate:assignment.dueDate]];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

@end
