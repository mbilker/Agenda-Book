
#import "NewAssignmentViewController.h"
#import "Assignment.h"
#import "Utils.h"

@implementation NewAssignmentViewController {
    NSDateFormatter *_dateFormatter;
}

@synthesize delegate;
@synthesize info;

@synthesize assignmentField;
@synthesize dateCell;
@synthesize duePicker;
@synthesize hiddenView;

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
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    self.assignmentField.delegate = self;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    [offset setDay:1];
    
    NSDate *minimum = [calendar dateByAddingComponents:offset toDate:[[Utils instance] dateWithOutTime:[NSDate date]] options:0];
    self.duePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    self.duePicker.minimumDate = minimum;
    
	self.dateCell.detailTextLabel.text = [_dateFormatter stringFromDate:minimum];
    
    [self.assignmentField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

- (void)checkDone
{
    if (self.assignmentField.text.length != 0) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Assignment"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(teacher == %@) AND (assignmentText == %@)", info, self.assignmentField.text];
        [fetchRequest setPredicate:predicate];
        NSArray *fetchedObjects = [[[Utils instance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if ([fetchedObjects count] > 0) {
            [[[UIAlertView alloc] initWithTitle:@"Other Assignment Exists" message:@"Another Assignment with that text exists in the list" delegate:self cancelButtonTitle:@"Rename" otherButtonTitles:nil] show];
            //NSLog(@"FOUND");
            return;
        }
        
        Assignment *assignment = [[Assignment alloc] initUsingDefaultContext];
        assignment.assignmentText = self.assignmentField.text;
        assignment.complete = FALSE;
        assignment.dueDate = [[Utils instance] dateWithOutTime:self.duePicker.date];
        assignment.teacher = self.info;
        [[Utils instance] saveContext];
        
        [self.delegate addAssignmentViewControllerAdded:self];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not enter an assignment" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [self checkDone];
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        if (![self.assignmentField isFirstResponder])
            [self.assignmentField becomeFirstResponder];
    } else if (indexPath.row == 1) {
        if ([self.assignmentField isFirstResponder]) {
            [self.assignmentField resignFirstResponder];
        }
        if (self.hiddenView.superview == nil) {
            NSLog(@"duePicker is not shown");
            [self.view.window addSubview:self.hiddenView];
            
            CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
            CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height, self.hiddenView.frame.size.width, self.hiddenView.frame.size.height);
            self.hiddenView.frame = startRect;
            
            CGRect pickerRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - self.hiddenView.frame.size.height, self.hiddenView.frame.size.width, self.hiddenView.frame.size.height);
            
            [UIView animateWithDuration:0.3f animations:^(void) {
                self.hiddenView.frame = pickerRect;
                
                CGRect newFrame = self.tableView.frame;
                newFrame.size.height -= self.hiddenView.frame.size.height;
                self.tableView.frame = newFrame;
            }];
        }
    }
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.hiddenView removeFromSuperview];
}

- (void)hideDuePicker
{
    if (self.hiddenView.superview != nil) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.hiddenView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        
        [UIView animateWithDuration:0.2f animations:^(void) {
            self.hiddenView.frame = endFrame;
            
            CGRect newFrame = self.tableView.frame;
            newFrame.size.height += self.hiddenView.frame.size.height;
            self.tableView.frame = newFrame;
        }];
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
	self.dateCell.detailTextLabel.text = [_dateFormatter stringFromDate:self.duePicker.date];
}

- (IBAction)done:(id)sender
{
    //NSLog(@"Date picked: %@",self.duePicker.date);
    //[self hideDuePicker];
    [self checkDone];
}

@end
