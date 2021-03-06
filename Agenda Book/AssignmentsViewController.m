
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "AssignmentsViewController.h"
#import "NewAssignmentViewController.h"
#import "EditAssignmentViewController.h"
#import "AssignmentCell.h"
#import "Assignment.h"
#import "Info.h"

#import "NSString-truncateToWidth.h"
#import "Utils.h"

@interface AssignmentsViewController () <NewAssignmentViewControllerDelegate, EditAssignmentViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) Assignment *assignmentForRow;

@end

@implementation AssignmentsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
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

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [Assignment MR_requestAllSortedBy:@"dueDate" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"teacher == %@", self.info]];
    
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:@"AgendaCache_Assignments"];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (BOOL)checkIfExists:(NSString *)adding
{
    NSUInteger count = [Assignment MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"assignmentText == %@", adding]];
    if (count > 0) return YES;
    return NO;
}

/*
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
                Assignment *assignment = [Assignment MR_createEntity];
                assignment.assignmentText = string;
                assignment.complete = FALSE;
                assignment.dueDate = date;
                assignment.teacher = self.info;
            }
        }
        [[Utils instance] saveContext];
        //NSArray* scienceArray = [json objectForKey:@"0"];
        //NSLog(@"%@: %@", [scienceArray objectAtIndex:1], scienceArray);
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Class not available" message:@"Either the server is not working properly or there is some other problem" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    }
}
*/

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddAssignment"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		NewAssignmentViewController *newAssignmnetViewController = [navigationController viewControllers][0];
		newAssignmnetViewController.delegate = self;
        newAssignmnetViewController.info = self.info;
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

- (IBAction)loadRemote:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Remote Disabled" message:@"Due to not having enough time to maintain the database, I have disabled this feature" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil] show];
    return;
    
    //if (![self.info.classid isEqualToString:@"0"]) {
    //    [self loadJSONRemote:self.info.classid];
    //} else {
    //    [[[UIAlertView alloc] initWithTitle:@"No Class ID" message:@"Class not linked to an online list" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
    //}
    //[self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[_fetchedResultsController sections][section] numberOfObjects];
}

- (void)configureCell:(AssignmentCell *)cell indexPath:(NSIndexPath *)indexPath
{
    Assignment *assignment = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Utils instance] colorForComplete:assignment.complete];
    cell.backgroundView = backgroundView;
    
    cell.assignment.text = assignment.assignmentText;
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
        [[NSManagedObjectContext MR_defaultContext] deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
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
    
    EditAssignmentViewController *edit = [self.storyboard instantiateViewControllerWithIdentifier:@"editAssignment"];
    edit.delegate = self;
    edit.assignment = _assignmentForRow;
    [self.navigationController pushViewController:edit animated:YES];
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
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(AssignmentCell *)[tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeMove:
            break;

        case NSFetchedResultsChangeUpdate:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[Utils instance] saveContext];
    [self.tableView endUpdates];
}

@end
