
#import <POP/POP.h>
#import <RWBlurPopover/RWBlurPopover.h>

#import "NewClassViewController.h"
#import "Info.h"
#import "Utils.h"

#define ERROR_BACKGROUND_COLOR [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f]

@implementation NewClassViewController
{
	NSString *_subject;
    
    CGFloat _originalTopContentInset;
    
    UIView *_errorView;
    UIView *_contentView;
    UILabel *_errorLabel;
    
    bool _errorViewLayoutDone;
    bool _errorViewDisplayed;
}

@synthesize delegate;
@synthesize teacherTextField;
@synthesize detailCell;
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
    
    [[Utils instance] initializeNavigationController:self.navigationController];
    
    self.teacherTextField.delegate = self;
    [self.teacherTextField becomeFirstResponder];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickSubjectDetail:)];
    [self.detailCell addGestureRecognizer:tapRecognizer];
}

- (void)viewDidLayoutSubviews
{
    if (!_errorViewLayoutDone) {
        _errorViewLayoutDone = true;
        
        _originalTopContentInset = self.tableView.contentInset.top;
        
        _errorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 0.0f)];
        _errorView.clipsToBounds = YES;
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _errorView.frame.size.width, 50.0f)];
        _contentView.backgroundColor = ERROR_BACKGROUND_COLOR;
        [_errorView addSubview:_contentView];
        
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.textAlignment = NSTextAlignmentCenter;
        _errorLabel.numberOfLines = 0;
        _errorLabel.opaque = TRUE;
        _errorLabel.frame = _contentView.frame;
        [_contentView addSubview:_errorLabel];
        
        [self.tableView addSubview:_errorView];
    }
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

- (void)clickSubjectDetail:(id)sender
{
    SubjectPickerViewController *subjectPickerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SubjectPickerViewController"];
    subjectPickerViewController.delegate = self;
    subjectPickerViewController.subject = _subject;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:subjectPickerViewController];
    
    [RWBlurPopover showContentViewController:navigationController insideViewController:self];
}

- (BOOL)checkDone
{
    if ([self.teacherTextField hasText] && ![_subject isEqualToString:@"Not Chosen"]) {
        [self dismissHeaderView];
        return TRUE;
    } else {
        NSString *line = [NSString stringWithFormat:@"%@%@", ![self.teacherTextField hasText] ? @"Teacher field empty\n" : @"", [_subject isEqualToString:@"Not Chosen"] ? @"Subject not chosen" : @""];
        
        //NSLog(@"Empty and did not choose subject");
        NSLog(@"Line: %@",line);
        
        _errorLabel.text = line;
        
        if (!_errorViewDisplayed) {
            _errorViewDisplayed = true;
            [UIView animateWithDuration:0.2f delay:0.0f usingSpringWithDamping:500.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^(void) {
                CGRect newFrame = _errorView.frame;
                newFrame.size.height = 50.0f;
                newFrame.origin.y = -50.0f;
                _errorView.frame = newFrame;
                
                UIEdgeInsets newInsets = self.tableView.contentInset;
                newInsets.top = _originalTopContentInset + 50.0f;
                self.tableView.contentInset = newInsets;
                
                self.tableView.contentOffset = CGPointMake(0.0f, -50.0f);
            } completion:nil];
        } else {
            [_contentView pop_removeAnimationForKey:@"flash"];
            
            POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            anim.fromValue = [UIColor colorWithRed:1.0f green:0.7f blue:0.5f alpha:1.0f];
            anim.toValue = ERROR_BACKGROUND_COLOR;
            [_contentView pop_addAnimation:anim forKey:@"flash"];
        }
    }
    return FALSE;
}

- (void)dismissHeaderView
{
    _errorViewDisplayed = false;
    [UIView animateWithDuration:0.2f delay:0.0f usingSpringWithDamping:500.0f initialSpringVelocity:0.0f options:UIViewAnimationOptionCurveLinear animations:^(void) {
        UIEdgeInsets newInsets = self.tableView.contentInset;
        newInsets.top = _originalTopContentInset;
        self.tableView.contentInset = newInsets;
        
        CGRect newFrame = _errorView.frame;
        newFrame.size.height = 0.0f;
        newFrame.origin.y = 0.0f;
        _errorView.frame = newFrame;
    } completion:nil];
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
