
#import "AssignmentsViewController.h"
#import "AssignmentCell.h"
#import "Assignment.h"
#import "NSString-truncateToWidth.h"
#import "Utils.h"

@implementation AssignmentsViewController {
    Assignment *_assignmentForRow;
}

@synthesize info;
@synthesize fetchedResultsController = _fetchedResultsController;

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

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:[[Utils instance] managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dueDate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacher == %@", info];
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[Utils instance] managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (BOOL)checkIfOnline:(NSURL *)url
{
    NSError *error;
    NSURLResponse *response;
	NSData *dataReply;
	NSString *stringReply;
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/check",classServer]]];
	[request setHTTPMethod: @"GET"];
	dataReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	stringReply = [[NSString alloc] initWithData:dataReply encoding:NSUTF8StringEncoding];
	
	if([stringReply isEqualToString:@"ok"]) return YES;
    return NO;
}

- (BOOL)checkIfExists:(NSString *)adding
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:[[Utils instance] managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assignmentText == %@", adding];
    [fetchRequest setPredicate:predicate];
    NSArray *fetchedObjects = [[[Utils instance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) return YES;
    return NO;
}

- (void)loadJSONRemote:(NSString *)class
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/class/%@",classServer,class]];
    if ([self checkIfOnline:url]) {
        NSError *error;
        NSData* data = [NSData dataWithContentsOfURL:url];
        NSArray *remoteArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //NSLog(@"JSON: %@",remoteArray);
        if ([remoteArray count] == 1) {
            [[[UIAlertView alloc] initWithTitle:@"No Assignments" message:@"Your teacher has not posted any assignments." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
            return;
        }
        for (NSString *string in remoteArray) {
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setDay:1];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *date = [gregorian dateByAddingComponents:components toDate:[NSDate date] options:0];
            
            if(![self checkIfExists:string]) {
                //[self.assignments addObject:adding];
                //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.assignments count] - 1 inSection:0];
                //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                Assignment *assignment = [NSEntityDescription insertNewObjectForEntityForName:@"Assignment" inManagedObjectContext:[[Utils instance] managedObjectContext]];
                assignment.assignmentText = string;
                assignment.complete = FALSE;
                assignment.dueDate = date;
                assignment.teacher = info;
            }
        }
        [[Utils instance] saveContext];
        //NSArray* scienceArray = [json objectForKey:@"0"];
        //NSLog(@"%@: %@", [scienceArray objectAtIndex:1], scienceArray);
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Class not available" message:@"Either the server is not working properly or there is some other problem" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
}

- (void)changeComplete:(NSIndexPath *)indexPath
{
    //NSLog(@"Row: '%d'",indexPath.row);
    //Assignment *changing = [self.assignments objectAtIndex:indexPath.row];
    Assignment *changing = [_fetchedResultsController objectAtIndexPath:indexPath];
    changing.complete = !changing.complete;
    //NSLog(@"Complete: '%@'",changing.complete ? @"YES" : @"NO");
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Utils instance] colorForComplete:changing.complete];
    cell.backgroundView = backgroundView;
    [[Utils instance] saveContext];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self loadFromPlist];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		//exit(-1);  // Fail
        abort();
	}
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
        newAssignmnetViewController.info = info;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (void)configureCell:(AssignmentCell *)cell indexPath:(NSIndexPath *)indexPath
{
    Assignment *assignment = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    CGSize maximumSize = CGSizeMake(280, 43);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = cell.assignment.lineBreakMode;
    NSDictionary *attributes = @{
        NSFontAttributeName: cell.assignment.font,
        NSParagraphStyleAttributeName: paragraphStyle
    };
    CGSize stringSize = [assignment.assignmentText boundingRectWithSize:cell.assignment.frame.size options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    CGRect cellFrame = CGRectMake(10, 10, 280, stringSize.height);
    cell.assignment.frame = cellFrame;
    
    NSArray *tokens = [assignment.assignmentText componentsSeparatedByString:@"\n"];
    //NSLog(@"Tokens: %@",tokens);
    NSMutableString *newString = [[NSMutableString alloc] init];
    for (NSString *token in tokens) {
        //NSLog(@"Trucated: %@",[token stringByTruncatingToWidth:self.tableView.frame.size.width withFont:cell.assignment.font]);
        [newString appendString:[token stringByTruncatingToWidth:cell.assignment.bounds.size.width withFont:cell.assignment.font]];
    }
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Utils instance] colorForComplete:assignment.complete];
    cell.backgroundView = backgroundView;
    
    cell.assignment.text = newString;
    cell.due.text = [NSString stringWithFormat:@"Due: %@",[[[Utils instance] GMTDateFormatter] stringFromDate:assignment.dueDate]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssignmentCell *cell = (AssignmentCell *)[tableView dequeueReusableCellWithIdentifier:@"AssignmentCell"];
    //NSLog(@"Assignment: '%@', Complete: '%@', Due: '%@'",atRow.assignmentText,atRow.complete ? @"YES" : @"NO",[atRow.dueDate description]);
    [self configureCell:cell indexPath:indexPath];
        
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
        [[[Utils instance] managedObjectContext] deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        [[Utils instance] saveContext];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _assignmentForRow = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *date = [[NSDateFormatter alloc] init];
    [date setDateStyle:NSDateFormatterShortStyle];
    NSString *line = [NSString stringWithFormat:@"Assignment: %@\nComplete: %@\nDue: %@", _assignmentForRow.assignmentText, _assignmentForRow.complete ? @"YES" : @"NO", [date stringFromDate:_assignmentForRow.dueDate]];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:line delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Assignment", nil];
    [actionSheet showInView:self.navigationController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && [[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Edit Assignment"]) {
        EditAssignmentViewController *edit = [self.storyboard instantiateViewControllerWithIdentifier:@"editAssignment"];
        edit.delegate = self;
        edit.assignment = _assignmentForRow;
        [self.navigationController pushViewController:edit animated:YES];
    }
}

#pragma mark - AddAssignmentViewControllerDelegate

- (void)addAssignmentViewControllerDidCancel:(AssignmentsViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addAssignmentViewControllerAdded:(AssignmentsViewController *)controller
{
    [self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EditAssignmentViewControllerDelegate

- (void)editAssignmentViewControllerDidCancel:(EditAssignmentViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editAssignmentViewController:(EditAssignmentViewController *)controller didChange:(NSDictionary *)assignment
{
    //NSLog(@"Assignment: '%@'",assignment.assignmentText);
    //NSLog(@"Complete: '%@'",assignment.complete ? @"YES" : @"NO");
    //NSLog(@"Due Date: '%@'",[assignment.dueDate description]);
    _assignmentForRow.assignmentText = [assignment valueForKey:@"assignmentText"];
    _assignmentForRow.complete = [[assignment valueForKey:@"complete"] boolValue];
    _assignmentForRow.dueDate = [assignment valueForKey:@"dueDate"];
    [[Utils instance] saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(AssignmentCell *)[tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[Utils instance] saveContext];
    [self.tableView endUpdates];
}

@end
