
#import "ClassesViewController.h"
#import "AssignmentsViewController.h"
#import "ClassDetailsViewController.h"
#import "EditClassViewController.h"
#import "AssignmentsMonthViewController.h"

#import "Info.h"
#import "SubjectCell.h"
#import "Functions.h"
#import "CustomAlert.h"

#import <Twitter/Twitter.h>

@implementation ClassesViewController {
    NSIndexPath *_rowtodelete;
    Info *infoForRow;
}

@synthesize editButton;
@synthesize managedObjectContext;
//@synthesize classes;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init ClassesViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc ClassesViewController");
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (BOOL)checkIfExists:(NSDictionary *)info
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //for (int i = 0; i < [self.classes count]; i++) {
    for (Info *currentClass in fetchedObjects) {
        //Info *currentClass = [self.classes objectAtIndex:i];
        if ([[info valueForKey:@"teacher"] isEqual:currentClass.teacher]) {
            //NSLog(@"Found %@ already exists",info.teacher);
            return YES;
        }
    }
    return NO;
}

- (void)saveClasses
{
    /* NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:20];
    for (int i = 0; i < [self.classes count]; i++)
    {
        Info *details = [self.classes objectAtIndex:i];
        //NSLog(@"Teacher: %@, Subject: %@, Complete: %@",details.teacher,details.subject,details.complete ? @"TRUE" : @"FALSE");
        [tempDict setObject:[NSArray arrayWithObjects:details.teacher,details.subject,details.classid, nil] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    [tempDict writeToFile:[[Functions sharedFunctions] classPath] atomically:YES];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"iCloud"] == 1) {
        NSURL *classesCloud = [[Functions sharedFunctions] classiCloud];
        [tempDict writeToURL:classesCloud atomically:YES];
    } */
    //NSLog(@"Classes array: %@", tempDict);
    NSError *error;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
}

/*
- (void)loadClasses
{
    NSDictionary *subjectsDict = [NSDictionary dictionaryWithContentsOfFile:[[Functions sharedFunctions] classPath]];
    for (int i = 0; i < [subjectsDict count]; i++)
    {
        NSArray *tempArray = [subjectsDict objectForKey:[NSString stringWithFormat:@"%d",i]];
        Info *info = [[Info alloc] init];
        info.teacher = [tempArray objectAtIndex:0];
        info.subject = [tempArray objectAtIndex:1];
        info.classid = [tempArray objectAtIndex:2];
        //NSLog(@"Teacher: %@, Subject: %@, Complete: %@",info.teacher,info.subject,info.complete ? @"TRUE" : @"FALSE");
        if (![self checkIfExists:info]) {
            //[self.classes addObject:info];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.classes count] - 1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    //self.classes = [subjectsDict valueForKey:@"Classes"];
} */

#pragma mark - View lifecycle

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
    self.fetchedResultsController = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    /* if ([[NSFileManager alloc] fileExistsAtPath:[[Functions sharedFunctions] classPath]]) {
        //NSLog(@"File Exists");
        [self loadClasses];
    } */
    
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Functions sharedFunctions] shouldAutorotate:interfaceOrientation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		NewClassViewController *newClassViewController = [[navigationController viewControllers] objectAtIndex:0];
		newClassViewController.delegate = self;
        newClassViewController.managedObjectContext = self.managedObjectContext;
	} else if ([segue.identifier isEqualToString:@"ShowAssignments"])
    {
        //Info *i = [self.classes objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
        Info *i = [_fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        //NSLog(@"Moving Teacher: %@, Subject: %@, Complete: %@",i.teacher,i.subject,i.complete ? @"TRUE" : @"FALSE");
        AssignmentsViewController *assignmentsViewController = segue.destinationViewController;
        assignmentsViewController.managedObjectContext = self.managedObjectContext;
        assignmentsViewController.info = i;
    } else if ([segue.identifier isEqualToString:@"AssignmentsMonth"])
    {
        AssignmentsMonthViewController *assignmentsMonthViewController = segue.destinationViewController;
        assignmentsMonthViewController.managedObjectContext = self.managedObjectContext;
    }
}

- (IBAction)tweet:(id)sender
{
    if ([TWTweetComposeViewController canSendTweet]) {
        int d = 0;
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (Info *i in fetchedObjects) {
            if ([[Functions sharedFunctions] determineClassComplete:i.teacher]) {
                d++;
            }
            //NSLog(@"Teacher: '%@', Complete: '%@'",i.teacher,[Functions determineClassComplete:i.teacher] ? @"YES" : @"NO");
        }
        NSString *s;
        if (!([fetchedObjects count] == 1)) {
            s = @"classes";
        } else {
            s = @"class";
        }
        NSString *f;
        if (!(d == 1)) {
            f = @"classes";
        } else {
            f = @"class";
        }
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"I'm using @mbilker's agenda book app for @TheQuenz. I have %d %@. Homework for %d %@ is complete.",[fetchedObjects count],s,d,f]];
	    [self presentModalViewController:tweetSheet animated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Twitter" message:@"Twitter is not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)editNavButtonPressed:(id)sender
{
    BOOL isEditing = !self.tableView.editing;
    [self.tableView setEditing:isEditing animated:YES];
    if (self.tableView.editing) {
        [self.editButton setTitle:@"Done"];
        self.editButton.style = UIBarButtonItemStyleDone;
    } else {
        [self.editButton setTitle:@"Edit"];
        self.editButton.style = UIBarButtonItemStyleBordered;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//return [self.classes count];
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Table view delegate

- (void)configureCell:(SubjectCell *)cell indexPath:(NSIndexPath *)indexPath
{
    Info *info = [_fetchedResultsController objectAtIndexPath:indexPath];
	cell.nameLabel.text = info.teacher;
	cell.gameLabel.text = info.subject;
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Functions sharedFunctions] determineClassComplete:info.teacher];
    cell.backgroundView = backgroundView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SubjectCell *cell = (SubjectCell *)[tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
	//Info *info = [self.classes objectAtIndex:indexPath.row];
    [self configureCell:cell indexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        CustomAlert *alert = [[CustomAlert alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
        [alert setBackgroundColor:[UIColor colorWithRed:0.55 green:0.2 blue:0.2 alpha:1.0] withStrokeColor:[UIColor colorWithHue:0.5 saturation:0.0 brightness:0.8 alpha:0.8]];
        [alert show];
        _rowtodelete = indexPath;

		//[self.classes removeObjectAtIndex:indexPath.row];
        //[self saveClasses];
		//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //_transferInfo = [self.classes objectAtIndex:indexPath.row];
    //NSLog(@"Moving Teacher: %@, Subject: %@, Complete: %@",_transferInfo.teacher,_transferInfo.subject,_transferInfo.complete ? @"TRUE" : @"FALSE");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Accessory tapped");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Teacher" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Class Details", @"Edit Class", nil];
    //infoForRow = [self.classes objectAtIndex:indexPath.row];
    infoForRow = [_fetchedResultsController objectAtIndexPath:indexPath];
    [actionSheet showInView:self.navigationController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Hit Button at: '%d'",buttonIndex);
    //NSLog(@"Button: '%@'",[actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0 && [actionSheet buttonTitleAtIndex:buttonIndex] == @"Class Details") {
        //NSLog(@"Class Details Hit");
        ClassDetailsViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"classDetailsView"];
        details.classInfo = infoForRow;
        [self.navigationController pushViewController:details animated:YES];
    } else if (buttonIndex == 1 && [actionSheet buttonTitleAtIndex:buttonIndex] == @"Edit Class") {
        EditClassViewController *editClass = [self.storyboard instantiateViewControllerWithIdentifier:@"editClass"];
        editClass.classInfo = infoForRow;
        editClass.delegate = self;
        [self.navigationController pushViewController:editClass animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //NSLog(@"ButtonIndex: '%d'",buttonIndex);
    if (buttonIndex == 1) {
        //[self.classes removeObjectAtIndex:_rowtodelete.row];
        [managedObjectContext deleteObject:[_fetchedResultsController objectAtIndexPath:_rowtodelete]];
        [self saveClasses];
		//[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_rowtodelete] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - PlayerDetailsViewControllerDelegate

- (void)newClassViewControllerDidCancel:(ClassesViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newClassViewController:(ClassesViewController *)controller didAddInfo:(NSDictionary *)newClass
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Info" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //for (int i = 0; i < [self.classes count]; i++) {
    for (Info *info in fetchedObjects) {
        //Info *info = [self.classes objectAtIndex:i];
        if ([info.teacher isEqual:[newClass valueForKey:@"teacher"]]) {
            NSLog(@"teacher1: '%@', teacher2: '%@'",info.teacher,[newClass valueForKey:@"teacher"]);
            [[[UIAlertView alloc] initWithTitle:@"Other Teacher Exists" message:@"Another Teacher with that name exists in the list" delegate:self cancelButtonTitle:@"Rename" otherButtonTitles:nil] show];
            //NSLog(@"FOUND");
            return;
        }
    }
    //[self.classes addObject:newClass];
    Info *info = [NSEntityDescription insertNewObjectForEntityForName:@"Info" inManagedObjectContext:self.managedObjectContext];
    info.teacher = [newClass valueForKey:@"teacher"];
    info.subject = [newClass valueForKey:@"subject"];
    info.classid = [newClass valueForKey:@"classid"];
    [self saveClasses];
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.classes count] - 1 inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EditClassViewControllerDelegate

- (void)editClassViewControllerDidCancel:(EditClassViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editClassViewController:(EditClassViewController *)controller didChange:(Info *)info
{
    //NSLog(@"Teacher: '%@'",info.teacher);
    //NSLog(@"Subject: '%@'",info.subject);
    //NSLog(@"Class ID: '%@'",info.classid);
    NSString *path = [[Functions sharedFunctions] assignmentPath];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        //NSLog(@"File Exists");
        NSMutableDictionary *teachersDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        NSArray *teacherAssignments = [teachersDict objectForKey:infoForRow.teacher];
        if (teacherAssignments != nil) {
            [teachersDict removeObjectForKey:infoForRow.teacher];
            [teachersDict setObject:teacherAssignments forKey:info.teacher];
            [teachersDict writeToFile:path atomically:YES];
        }
    }
    infoForRow.teacher = info.teacher;
    infoForRow.subject = info.subject;
    infoForRow.classid = info.classid;
    [self saveClasses];
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
            [self configureCell:(SubjectCell *)[tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
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
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
