
#import "NewClassViewController.h"
#import "Info.h"
#import "Utils.h"

@implementation NewClassViewController
{
	NSString *subject;
}

@synthesize delegate;
@synthesize teacherTextField;
@synthesize detailLabel;
@synthesize classIdField;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init NewClassViewController");
        
		subject = @"Not Chosen";
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc NewClassViewController");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PickSubject"])
	{
        //NSLog(@"Segue");
		SubjectPickerViewController *subjectPickerViewController = segue.destinationViewController;
		subjectPickerViewController.delegate = self;
		subjectPickerViewController.subject = subject;
	}
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
	self.detailLabel.text = subject;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.teacherTextField.delegate = self;
    [self.teacherTextField becomeFirstResponder];
    
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

- (IBAction)cancel:(id)sender
{
	[self.delegate newClassViewControllerDidCancel:self];
}

- (void)checkDone
{
    if ([self.teacherTextField hasText] && ![subject isEqualToString:@"Not Chosen"]) {
        [self.delegate newClassViewController:self didAddInfo:@{
            @"teacher": self.teacherTextField.text,
            @"subject": subject,
            @"classid": self.classIdField.text
        }];
    } else {
        NSString *line = [NSString stringWithFormat:@"%@%@", ![self.teacherTextField hasText] ? @"Teacher field empty" : @"", [subject isEqualToString:@"Not Chosen"] ? @"\nSubject not chosen" : @""];
        
        //NSLog(@"Empty and did not choose subject");
        UIView *errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50.0f)];
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, errorView.frame.size.width, 0)];
        //contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        CGRect contentViewFrame = contentView.frame;
        contentViewFrame.size.height = errorView.frame.size.height;
        
        contentView.backgroundColor = [UIColor redColor];
        [errorView addSubview:contentView];
        
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.numberOfLines = 0;
        label.opaque = TRUE;
        label.text = line;
        label.frame = contentView.frame;
        [contentView addSubview:label];
        
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:500.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^(void) {
            self.tableView.tableHeaderView = errorView;
            contentView.frame = contentViewFrame;
            label.frame = errorView.frame;
        } completion:nil];
        //[[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not fill in the teacher or select a subject" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (void)dismissHeaderView
{
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:500.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^(void) {
        self.tableView.tableHeaderView.frame = CGRectMake(0, 0, self.tableView.tableHeaderView.frame.size.width, 0);
    } completion:^(BOOL complete) {
        [self.tableView.tableHeaderView removeFromSuperview];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    //NSLog(@"Done button hit");
    [self checkDone];
    return NO;
}

- (IBAction)done:(id)sender
{
    [self checkDone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0) {
		[self.teacherTextField becomeFirstResponder];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        [self.classIdField becomeFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.classIdField != textField) return;
    
    NSString *test = [string stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    //NSLog(@"Other trimmed: %@, length: %d", test, test.length);
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //NSLog(@"space: '%d', newString: '%@', compare: '%@'", [string isEqualToString:@" "], newString, string);
    if (![string isEqualToString:@" "] && [string stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].length > 0) {
        if (textField.text.length == 3) {
            textField.text = [newString substringWithRange:NSMakeRange(1, newString.length - 2)];
        }
        return TRUE;
    } else if ([string isEqualToString:@""]) {
        return TRUE;
    }
    return FALSE;
}

#pragma mark - SubjectPickerViewControllerDelegate

- (void)subjectPickerViewController:(SubjectPickerViewController *)controller didSelectSubject:(NSString *)theSubject
{
	self.detailLabel.text = subject = theSubject;
	[self.navigationController popViewControllerAnimated:YES];
}

@end
