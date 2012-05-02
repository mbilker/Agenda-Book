
#import "AssignmentsViewController.h"
#import "AssignmentCell.h"
#import "Assignment.h"
#import "AssignmentDetailsViewController.h"
#import "EditAssignmentViewController.h"
#import "NewAssignmentViewController.h"
#import "NSString-truncateToWidth.h"
#import "Functions.h"
// #import "Info.h"

/* #define server @"localhost:8080" */
#define server @"9.classes.mbilker.us"

@implementation AssignmentsViewController {
    Assignment *assignmentForRow;
}

@synthesize assignments;
@synthesize info;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init AssignmentsViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc AssignmentsViewController");
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)makePlist
{
    if (![[NSFileManager alloc] fileExistsAtPath:[[Functions sharedFunctions] assignmentPath]]) {
        NSDictionary *d = [NSDictionary dictionary];
        //NSLog(@"Success: '%@'",[d writeToFile:path atomically:YES] ? @"YES" : @"NO");
        [d writeToFile:[[Functions sharedFunctions] assignmentPath] atomically:YES];
    }
}

- (void)saveAssignments
{
    [self makePlist];
    NSString *path = [[Functions sharedFunctions] assignmentPath];
    NSMutableDictionary *currentDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary *teacherDict = [NSMutableDictionary dictionaryWithCapacity:20];
    for (int i = 0; i < [self.assignments count]; i++)
    {
        Assignment *saving = [self.assignments objectAtIndex:i];
        //NSLog(@"assignment: '%@' complete: '%@'",saving.assignmentText,saving.complete ? @"YES" : @"NO");
        [teacherDict setObject:[NSArray arrayWithObjects:saving.assignmentText, [NSNumber numberWithBool:saving.complete], saving.dueDate, nil] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    [currentDict setObject:teacherDict forKey:info.teacher];
    //NSLog(@"Assignments array: '%@'", currentDict);
    [currentDict writeToFile:path atomically:YES];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"iCloud"] == 1) {
        NSURL *icloud = [[Functions sharedFunctions] assignmentiCloud];
        [currentDict writeToURL:icloud atomically:YES];
    }
    //BOOL s = [currentDict writeToFile:path atomically:YES];
    //NSLog(@"Succeeded: '%@'",s ? @"YES" : @"NO");
    //NSLog(@"Assignments array: %@", teacherDict);
    //NSLog(@"Teacher: '%@'",info.teacher);
}

- (BOOL)checkIfOnline:(NSURL *)url
{
    NSError *error;
    NSURLResponse *response;
	NSData *dataReply;
	NSString *stringReply;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/check",server]]];
	[request setHTTPMethod: @"GET"];
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	
	if([@"ok" isEqualToString:stringReply]) return YES;
    return NO;
}

- (BOOL)checkIfExists:(Assignment *)adding
{
    for (int i = 0; i < [self.assignments count]; i++) {
        Assignment *alreadyIn = [self.assignments objectAtIndex:i];
        if([alreadyIn.assignmentText isEqual:adding.assignmentText]) {
            //NSLog(@"Found '%@' already exists",adding.assignmentText);
            return YES;
        }
    }
    return NO;
}

- (void)loadJSONRemote:(NSString *)class
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/class/%@",server,class]];
    if ([self checkIfOnline:url]) {
        NSError *error;
        NSData* data = [NSData dataWithContentsOfURL:url];
        NSArray *remoteArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //NSLog(@"JSON: %@",remoteArray);
        if ([remoteArray count] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"No Assignments" message:@"Your teacher has not posted any assignments." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
            return;
        }
        for (NSString *string in remoteArray) {
            Assignment *adding = [[Assignment alloc] init];
            adding.assignmentText = string;
            adding.complete = FALSE;
            
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:1];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateByAddingComponents:components toDate:[NSDate date] options:0];
            adding.dueDate = date;
            if(![self checkIfExists:adding]) {
                [self.assignments addObject:adding];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.assignments count] - 1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        [self saveAssignments];
        //NSArray* scienceArray = [json objectForKey:@"0"];
        //NSLog(@"%@: %@", [scienceArray objectAtIndex:1], scienceArray);
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Class not available" message:@"Either the server is not working properly or there is some other problem" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
}

- (void)loadFromPlist
{
    NSString *path = [[Functions sharedFunctions] assignmentPath];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        //NSLog(@"File Exists");
        NSDictionary *subjectsDict = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:info.teacher];
        for (int i = 0; i < [subjectsDict count]; i++)
        {
            NSArray *assignmentFromPlist = [subjectsDict objectForKey:[NSString stringWithFormat:@"%d",i]];
            Assignment *adding = [[Assignment alloc] init];
            adding.assignmentText = [assignmentFromPlist objectAtIndex:0];
            adding.complete = [[assignmentFromPlist objectAtIndex:1] boolValue];
            //NSLog(@"%@<%p> = '%@'",[[assignmentFromPlist objectAtIndex:2] class],[assignmentFromPlist objectAtIndex:2],[assignmentFromPlist objectAtIndex:2]);
            adding.dueDate = [assignmentFromPlist objectAtIndex:2];
            //NSLog(@"Teacher: %@, Subject: %@, Complete: %@",info.teacher,info.subject,info.complete ? @"TRUE" : @"FALSE");
            if (![self checkIfExists:adding]) {
                [self.assignments addObject:adding];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.assignments count] - 1 inSection:0];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }
    }
}

- (void)changeComplete:(NSIndexPath *)indexPath
{
    //NSLog(@"Row: '%d'",indexPath.row);
    Assignment *changing = [self.assignments objectAtIndex:indexPath.row];
    changing.complete = !changing.complete;
    //NSLog(@"Complete: '%@'",changing.complete ? @"YES" : @"NO");
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Functions sharedFunctions] colorForComplete:changing.complete];
    cell.backgroundView = backgroundView;
    [self saveAssignments];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadFromPlist];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddAssignment"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		NewAssignmentViewController *newAssignmnetViewController = [[navigationController viewControllers] objectAtIndex:0];
		newAssignmnetViewController.delegate = self;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Functions sharedFunctions] shouldAutorotate:interfaceOrientation];
}

- (IBAction)loadRemote:(id)sender
{
    if (![info.classid isEqualToString:@"0"]) {
        [self loadJSONRemote:info.classid];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Class ID" message:@"Class not linked to an online list" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.assignments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssignmentCell *cell = (AssignmentCell *)[tableView dequeueReusableCellWithIdentifier:@"AssignmentCell"];
    Assignment *atRow = [self.assignments objectAtIndex:indexPath.row];
    //NSLog(@"Assignment: '%@', Complete: '%@', Due: '%@'",atRow.assignmentText,atRow.complete ? @"YES" : @"NO",[atRow.dueDate description]);
    CGSize maximumSize = CGSizeMake(280, 43);
    CGSize stringSize = [atRow.assignmentText sizeWithFont:cell.assignment.font constrainedToSize:maximumSize lineBreakMode:cell.assignment.lineBreakMode];
    CGRect cellFrame = CGRectMake(10, 10, 280, stringSize.height);
    cell.assignment.frame = cellFrame;
    
    NSArray *tokens = [atRow.assignmentText componentsSeparatedByString:@"\n"];
    //NSLog(@"Tokens: %@",tokens);
    NSMutableString *newString = [[NSMutableString alloc] init];
    for (NSString *token in tokens) {
        //NSLog(@"Trucated: %@",[token stringByTruncatingToWidth:self.tableView.frame.size.width withFont:cell.assignment.font]);
        [newString appendString:[token stringByTruncatingToWidth:cell.assignment.bounds.size.width withFont:cell.assignment.font]];
    }
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Functions sharedFunctions] colorForComplete:atRow.complete];
    cell.backgroundView = backgroundView;
    
    cell.assignment.text = newString;
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateStyle:NSDateFormatterShortStyle];
    cell.due.text = [NSString stringWithFormat:@"Due: %@",[date stringFromDate:atRow.dueDate]];
    //[cell.assignment sizeToFit];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Picked: %@ index", indexPath);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self changeComplete:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.assignments removeObjectAtIndex:indexPath.row];
        [self saveAssignments];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Accessory tapped");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Assignment Details", @"Edit Assignment", nil];
    assignmentForRow = [self.assignments objectAtIndex:indexPath.row];
    [actionSheet showInView:self.navigationController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Hit Button at: '%d'",buttonIndex);
    //NSLog(@"Button: '%@'",[actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0 && [actionSheet buttonTitleAtIndex:buttonIndex] == @"Assignment Details") {
        AssignmentDetailsViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"assignmentDetailsView"];
        details.assignment = assignmentForRow;
        [self.navigationController pushViewController:details animated:YES];
    } else if (buttonIndex == 1 && [actionSheet buttonTitleAtIndex:buttonIndex] == @"Edit Assignment") {
        NSLog(@"Edit assignment");
        EditAssignmentViewController *edit = [self.storyboard instantiateViewControllerWithIdentifier:@"editAssignment"];
        edit.delegate = self;
        edit.assignment = assignmentForRow;
        [self.navigationController pushViewController:edit animated:YES];
    }
}

#pragma mark - AddAssignmentViewControllerDelegate

- (void)addAssignmentViewControllerDidCancel:(AssignmentsViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAssignmentViewController:(AssignmentsViewController *)controller didAddAssignment:(Assignment *)newAssignment
{
    for (int i = 0; i < [self.assignments count]; i++) {
        Assignment *assignment = [self.assignments objectAtIndex:i];
        if ([assignment.assignmentText isEqual:newAssignment.assignmentText]) {
            [[[UIAlertView alloc] initWithTitle:@"Other Assignment Exists" message:@"Another Assignment with that text exists in the list" delegate:self cancelButtonTitle:@"Rename" otherButtonTitles:nil] show];
            //NSLog(@"FOUND");
            return;
        }
    }
    [self.assignments addObject:newAssignment];
    [self saveAssignments];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.assignments count] - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EditAssignmentViewControllerDelegate

- (void)editAssignmentViewControllerDidCancel:(EditAssignmentViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editAssignmentViewController:(EditAssignmentViewController *)controller didChange:(Assignment *)assignment
{
    //NSLog(@"Assignment: '%@'",assignment.assignmentText);
    //NSLog(@"Complete: '%@'",assignment.complete ? @"YES" : @"NO");
    //NSLog(@"Due Date: '%@'",[assignment.dueDate description]);
    assignmentForRow.assignmentText = assignment.assignmentText;
    assignmentForRow.complete = assignment.complete;
    assignmentForRow.dueDate = assignment.dueDate;
    [self saveAssignments];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
