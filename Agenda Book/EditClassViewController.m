
#import "EditClassViewController.h"
#import "SubjectPickerViewController.h"
#import "ClassIDViewController.h"

#import "Functions.h"

@implementation EditClassViewController {
    NSMutableDictionary *tempInfo;
}

@synthesize delegate;
@synthesize subjectDetail;
@synthesize classIDDetail;
@synthesize teacherField;

@synthesize classInfo;
@synthesize managedObjectContext;

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
        subjectPickerViewController.managedObjectContext = self.managedObjectContext;
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
    //tempInfo = [[Info alloc] init];
    //tempInfo.subject = self.classInfo.subject;
    //tempInfo.teacher = self.classInfo.teacher;
    //tempInfo.classid = self.classInfo.classid;
    tempInfo = [NSMutableDictionary dictionary];
    [tempInfo setValue:self.classInfo.subject forKey:@"subject"];
    [tempInfo setValue:self.classInfo.teacher forKey:@"teacher"];
    [tempInfo setValue:self.classInfo.classid forKey:@"classid"];
    
    self.subjectDetail.text = [tempInfo valueForKey:@"subject"];
    self.classIDDetail.text = [tempInfo valueForKey:@"classid"];
    self.teacherField.text = [tempInfo valueForKey:@"teacher"];
    
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
        //tempInfo.subject = self.subjectDetail.text;
        //tempInfo.teacher = self.teacherField.text;
        //tempInfo.classid = self.classIDDetail.text;
        [tempInfo setValue:self.subjectDetail.text forKey:@"subject"];
        [tempInfo setValue:self.teacherField.text forKey:@"teacher"];
        [tempInfo setValue:self.classIDDetail.text forKey:@"classid"];
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
    //tempInfo.subject = theSubject;
    [tempInfo setValue:theSubject forKey:@"subject"];
	self.subjectDetail.text = [tempInfo valueForKey:@"subject"];
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ClassIDViewControllerDelegate

- (void)classIDViewControllerDidCancel:(ClassIDViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)classIDViewController:(ClassIDViewController *)controller didAddClassID:(NSString *)classID
{
    //tempInfo.classid = classID;
    [tempInfo setValue:classID forKey:@"classid"];
    self.classIDDetail.text = [tempInfo valueForKey:@"classid"];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
