
#import "EditAssignmentViewController.h"
#import "Functions.h"

@implementation EditAssignmentViewController {
    NSMutableDictionary *tempAssignment;
}

@synthesize delegate;
@synthesize assignmentField;
@synthesize dueCell;
@synthesize duePicker;
@synthesize dateFormatter;
@synthesize assignment;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
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
    
    self.assignmentField.delegate = self;
    
    //tempAssignment = [[Assignment alloc] init];
    //tempAssignment.assignmentText = self.assignment.assignmentText;
    //tempAssignment.complete = self.assignment.complete;
    //tempAssignment.dueDate = self.assignment.dueDate;
    tempAssignment = [NSMutableDictionary dictionary];
    [tempAssignment setValue:self.assignment.assignmentText forKey:@"assignmentText"];
    [tempAssignment setValue:[NSNumber numberWithBool:self.assignment.complete] forKey:@"complete"];
    [tempAssignment setValue:self.assignment.dueDate forKey:@"dueDate"];
    
    
    self.assignmentField.text = [tempAssignment valueForKey:@"assignmentText"];
    [self.assignmentField becomeFirstResponder];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:1];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *minimum = [gregorian dateByAddingComponents:components toDate:[NSDate date] options:0];
    self.duePicker.minimumDate = minimum;
    self.duePicker.date = [tempAssignment valueForKey:@"dueDate"];
    
	self.dueCell.detailTextLabel.text = [self.dateFormatter stringFromDate:minimum];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Functions sharedFunctions] shouldAutorotate:interfaceOrientation];
}

- (void)checkDone
{
    if (self.assignmentField.text.length != 0) {
        //tempAssignment.assignmentText = self.assignmentField.text;
        //tempAssignment.dueDate = self.duePicker.date;
        [tempAssignment setValue:self.assignment.assignmentText forKey:@"assignmentText"];
        [tempAssignment setValue:self.assignment.dueDate forKey:@"dueDate"];
        [self.delegate editAssignmentViewController:self didChange:tempAssignment];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not enter an assignment" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //NSLog(@"indexPath: '%d'", indexPath.row);
    if (indexPath.row == 0) {
        [self.assignmentField becomeFirstResponder];
    }
    if (indexPath.row == 1) {
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
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
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
	[self.delegate editAssignmentViewControllerDidCancel:self];
}

- (IBAction)dateChanged:(id)sender
{
	self.dueCell.detailTextLabel.text = [self.dateFormatter stringFromDate:self.duePicker.date];
}

- (IBAction)done:(id)sender
{
    //NSLog(@"Date picked: %@",self.duePicker.date);
    [self hideDuePicker];
    [self checkDone];
}

@end
