
#import "NewAssignmentViewController.h"
#import "Assignment.h"
#import "Functions.h"

@implementation NewAssignmentViewController

@synthesize delegate;
@synthesize assignmentField;
@synthesize dateCell;
@synthesize duePicker;
@synthesize dateFormatter;

//static int calendarShadowOffset = (int)-20;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    self.assignmentField.delegate = self;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    [offset setDay:1];
    
    NSDate *minimum = [calendar dateByAddingComponents:offset toDate:[[Functions sharedFunctions] dateWithOutTime:[NSDate date]] options:0];
    self.duePicker.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    self.duePicker.minimumDate = minimum;
    
	self.dateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:minimum];
    
    [self.assignmentField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Functions sharedFunctions] shouldAutorotate:interfaceOrientation];
}

- (void)checkDone
{
    if (self.assignmentField.text.length != 0) {
        //Assignment *assignment = [[Assignment alloc] init];
        //assignment.assignmentText = self.assignmentField.text;
        //assignment.complete = FALSE;
        //assignment.dueDate = self.duePicker.date;
        NSDictionary *assignment = [NSDictionary dictionaryWithObjectsAndKeys:self.assignmentField.text, @"assignmentText", [NSNumber numberWithBool:FALSE], @"complete", [[Functions sharedFunctions] dateWithOutTime:self.duePicker.date], @"dueDate", nil];
        [self.delegate addAssignmentViewController:self didAddAssignment:assignment];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not enter an assignment" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    //NSLog(@"Done button hit");
    [self checkDone];
    //[theTextField resignFirstResponder];
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"indexPath: '%d'", indexPath.row);
    if (indexPath.row == 0) {
        if (![self.assignmentField isFirstResponder])
            [self.assignmentField becomeFirstResponder];
    } else if (indexPath.row == 1) {
        //NSLog(@"second row");
        if ([self.assignmentField isFirstResponder]) {
            //NSLog(@"resigning");
            [self.assignmentField resignFirstResponder];
        }
        if (self.duePicker.superview == nil) {
            NSLog(@"duePicker is not shown");
            [self.view.window addSubview:self.duePicker];
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGSize pickerSize = [self.duePicker sizeThatFits:CGSizeZero];
            CGRect startRect = CGRectMake(0.0,
                                          screenRect.origin.y + screenRect.size.height,
                                          pickerSize.width, pickerSize.height);
            self.duePicker.frame = startRect;
            
            // compute the end frame
            CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - pickerSize.height, pickerSize.width, pickerSize.height);
            // start the slide up animation
            [UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
            
			// we need to perform some post operations after the animation is complete
			[UIView setAnimationDelegate:self];
            
			self.duePicker.frame = pickerRect;
            
			// shrink the table vertical size to make room for the date picker
			CGRect newFrame = self.tableView.frame;
			newFrame.size.height -= self.duePicker.frame.size.height;
			self.tableView.frame = newFrame;
            [UIView commitAnimations];
        }
    }
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.duePicker removeFromSuperview];
}

- (void)hideDuePicker
{
    if (self.duePicker.superview != nil) {
        CGRect
        screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.duePicker.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        
		// we need to perform some post operations after the animation is complete
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
		self.duePicker.frame = endFrame;
        [UIView commitAnimations];
        
        // grow the table back again in vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height += self.duePicker.frame.size.height;
        self.tableView.frame = newFrame;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hideDuePicker];
}

- (IBAction)cancel:(id)sender
{
    [self hideDuePicker];
	[self.delegate addAssignmentViewControllerDidCancel:self];
}

- (IBAction)dateChanged:(id)sender
{
	self.dateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.duePicker.date];
}

- (IBAction)done:(id)sender
{
    //NSLog(@"Date picked: %@",self.duePicker.date);
    [self hideDuePicker];
    [self checkDone];
}
@end
