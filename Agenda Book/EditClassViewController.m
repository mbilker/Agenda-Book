
#import "EditClassViewController.h"
#import "SubjectPickerViewController.h"
#import "ClassIDViewController.h"

#import "Info.h"
#import "Functions.h"

@implementation EditClassViewController {
    Info *tempInfo;
}

@synthesize delegate;
@synthesize subjectDetail;
@synthesize classInfo;
@synthesize classIDDetail;
@synthesize teacherField;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init EditClassViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc EditClassViewController");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"changeSubject"])
	{
        //NSLog(@"Segue");
		SubjectPickerViewController *subjectPickerViewController = segue.destinationViewController;
		subjectPickerViewController.delegate = self;
		subjectPickerViewController.subject = self.classInfo.subject;
	}
    if ([segue.identifier isEqualToString:@"changeClassID"])
	{
        //NSLog(@"Segue");
		ClassIDViewController *classIDPickerViewController = segue.destinationViewController;
		classIDPickerViewController.delegate = self;
		//classIDPickerViewController.enteredClassID = tableClassID;
	}
}

- (void)viewDidLoad
{
    tempInfo = [[Info alloc] init];
    tempInfo.subject = self.classInfo.subject;
    tempInfo.teacher = self.classInfo.teacher;
    tempInfo.classid = self.classInfo.classid;
    
    self.subjectDetail.text = tempInfo.subject;
    self.classIDDetail.text = tempInfo.classid;
    self.teacherField.text = tempInfo.teacher;
    
    [self.teacherField becomeFirstResponder];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Functions sharedFunctions] shouldAutorotate:interfaceOrientation];
}

- (IBAction)cancel:(id)sender
{
    [self.delegate editClassViewControllerDidCancel:self];
}

- (void)checkDone
{
    if ([self.teacherField hasText]) {
        tempInfo.subject = self.subjectDetail.text;
        tempInfo.teacher = self.teacherField.text;
        tempInfo.classid = self.classIDDetail.text;
        [self.delegate editClassViewController:self didChange:tempInfo];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not fill in the teacher" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self checkDone];
    return NO;
}

- (IBAction)done:(id)sender
{
    [self checkDone];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SubjectPickerViewControllerDelegate

- (void)subjectPickerViewController:(SubjectPickerViewController *)controller didSelectSubject:(NSString *)theSubject
{
    tempInfo.subject = theSubject;
	self.subjectDetail.text = tempInfo.subject;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ClassIDViewControllerDelegate

- (void)classIDViewControllerDidCancel:(ClassIDViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)classIDViewController:(ClassIDViewController *)controller didAddClassID:(NSString *)classID
{
    tempInfo.classid = classID;
    self.classIDDetail.text = tempInfo.classid;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
