
#import "AddSubjectPickerViewController.h"
#import "Utils.h"

@implementation AddSubjectPickerViewController

@synthesize delegate;
@synthesize subjectTextField;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init AddSubjectPickerViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc AddSubjectPickerViewController");
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self.subjectTextField becomeFirstResponder];
    self.subjectTextField.delegate = self;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

- (void)checkDone
{
    if ([self.subjectTextField hasText]) {
        [self.delegate addSubjectPickerViewController:self subject:self.subjectTextField.text];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not enter an subject" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //NSLog(@"Done button hit");
    [self checkDone];
    return NO;
}

- (IBAction)done:(id)sender
{
    [self checkDone];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate addSubjectPickerViewControllerDidCancel:self];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
