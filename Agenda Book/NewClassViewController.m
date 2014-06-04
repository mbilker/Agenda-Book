
#import "NewClassViewController.h"
#import "Info.h"
#import "Utils.h"

@implementation NewClassViewController
{
	NSString *_subject;
    UIView *_errorView;
    UIView *_contentView;
    UILabel *_errorLabel;
}

@synthesize delegate;
@synthesize teacherTextField;
@synthesize detailLabel;
@synthesize classIdField;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init NewClassViewController");
        
		_subject = @"Not Chosen";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	}
	return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)dealloc
{
	NSLog(@"dealloc NewClassViewController");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PickSubject"]) {
        //NSLog(@"Segue");
		SubjectPickerViewController *subjectPickerViewController = segue.destinationViewController;
		subjectPickerViewController.delegate = self;
		subjectPickerViewController.subject = _subject;
	}
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
    [super viewDidLoad];
    
	self.detailLabel.text = _subject;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.teacherTextField.delegate = self;
    [self.teacherTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.teacherTextField resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

- (IBAction)cancel:(id)sender
{
	[self.delegate newClassViewControllerDidCancel:self];
}

- (BOOL)checkDone
{
    if ([self.teacherTextField hasText] && ![_subject isEqualToString:@"Not Chosen"]) {
        [self dismissHeaderView];
        return TRUE;
    } else {
        NSString *line = [NSString stringWithFormat:@"%@%@", ![self.teacherTextField hasText] ? @"Teacher field empty\n" : @"", [_subject isEqualToString:@"Not Chosen"] ? @"Subject not chosen" : @""];
        
        //NSLog(@"Empty and did not choose subject");
        if (_errorView == nil) {
            _errorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50.0f)];
        }
        if (_contentView == nil) {
            _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _errorView.frame.size.width, 0)];
            _contentView.backgroundColor = [UIColor redColor];
            [_errorView addSubview:_contentView];
        }
        
        if (_errorLabel == nil) {
            _errorLabel = [[UILabel alloc] init];
            [_errorLabel setTextAlignment:NSTextAlignmentCenter];
            _errorLabel.numberOfLines = 0;
            _errorLabel.opaque = TRUE;
            _errorLabel.frame = _contentView.frame;
            [_contentView addSubview:_errorLabel];
        }
        
        _errorLabel.text = line;
        
        if (self.tableView.tableHeaderView.superview == nil) {
            CGRect contentViewFrame = _contentView.frame;
            contentViewFrame.size.height = _errorView.frame.size.height;
            [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:500.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^(void) {
                self.tableView.tableHeaderView = _errorView;
                _contentView.frame = contentViewFrame;
                _errorLabel.frame = _errorView.frame;
            } completion:nil];
        }
    }
    return FALSE;
}

- (void)dismissHeaderView
{
    [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:500.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^(void) {
        _contentView.frame = _errorView.frame = CGRectMake(0, 0, _errorView.frame.size.width, 0);
    } completion:^(BOOL complete) {
        [_errorView removeFromSuperview];
    }];
}

- (IBAction)done:(id)sender
{
    if ([self checkDone]) {
        [self.delegate newClassViewController:self didAddInfo:@{
            @"teacher": self.teacherTextField.text,
            @"subject": _subject,
            @"classid": self.classIdField.text
        }];
    }
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

- (void)textFieldDidChange:(NSNotification *)notification
{
    [self checkDone];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    //NSLog(@"Done button hit");
    [self checkDone];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.classIdField != textField) return TRUE;
    
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
	self.detailLabel.text = _subject = theSubject;
	[self.navigationController popViewControllerAnimated:YES];
    [self checkDone];
}

@end
