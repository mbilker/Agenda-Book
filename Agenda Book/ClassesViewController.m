
#import <Social/Social.h>

#import "ClassesViewController.h"
#import "AssignmentsViewController.h"
#import "ClassDetailsViewController.h"

#import "Info.h"
#import "SubjectCell.h"
#import "Utils.h"

@implementation ClassesViewController {
    NSIndexPath *_rowtodelete;
    BOOL _updateAvailable;
    BOOL _updateChecked;
    BOOL _ready;
    Info *_infoForRow;
    
    UIView *_iAdContainer;
}

@synthesize editButton;
@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize iAdBanner;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		NSLog(@"init ClassesViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc ClassesViewController");
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)reloadFetchedResults:(NSNotification*)note {
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /* TODO
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }             
    
    if (note) {
        [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _updateChecked = FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:@"RefetchAllDatabaseData" object:[[UIApplication sharedApplication] delegate]];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// TODO Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.fetchedResultsController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		NewClassViewController *newClassViewController = [[navigationController viewControllers] objectAtIndex:0];
		newClassViewController.delegate = self;
	} else if ([segue.identifier isEqualToString:@"ShowAssignments"]) {
        //Info *i = [self.classes objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
        Info *i = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        //NSLog(@"Moving Teacher: %@, Subject: %@, Complete: %@",i.teacher,i.subject,i.complete ? @"TRUE" : @"FALSE");
        AssignmentsViewController *assignmentsViewController = segue.destinationViewController;
        assignmentsViewController.info = i;
        NSLog(@"Teacher Rel: %@", i.assignments);
    }
}

- (IBAction)tweet:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        int d = 0;
        for (Info *i in self.fetchedResultsController.fetchedObjects) {
            if ([[Utils instance] determineClassComplete:i]) {
                d++;
            }
            NSLog(@"Teacher: '%@', Complete: '%@'", i.teacher, [[Utils instance] determineClassComplete:i] ? @"YES" : @"NO");
        }
        
        NSString *s = ([self.fetchedResultsController.fetchedObjects count] != 1) ? @"classes" : @"class";
        NSString *f = (d != 1) ? @"classes" : @"class";
        
        SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitter setInitialText:[NSString stringWithFormat:@"I'm using @mbilker's agenda book app for @TheQuenz. I have %d %@. Homework for %d %@ is complete.", [self.fetchedResultsController.fetchedObjects count], s, d, f]];
	    [self presentViewController:twitter animated:YES completion:nil];
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
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Table view delegate

- (void)configureCell:(SubjectCell *)cell indexPath:(NSIndexPath *)indexPath
{
    Info *info = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.nameLabel.text = info.teacher;
	cell.gameLabel.text = info.subject;
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [[Utils instance] determineClassCompleteColor:info];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete",nil];
        //[alert setBackgroundColor:[UIColor colorWithRed:0.55 green:0.2 blue:0.2 alpha:1.0] withStrokeColor:[UIColor colorWithHue:0.5 saturation:0.0 brightness:0.8 alpha:0.8]];
        [alert show];
        
        _rowtodelete = indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    _infoForRow = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Assignment"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"teacher == %@", _infoForRow]];
    int i = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] count];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"teacher == %@ AND complete == 1", _infoForRow]];
    int c = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] count];
    int f = i - c;
    
    NSString *title = [NSString stringWithFormat:@"Teacher: %@\nSubject: %@\nID: %@\n\nAssignments: %d\nComplete Assignments: %d\nIncomplete Assignments: %d", _infoForRow.teacher, _infoForRow.subject, _infoForRow.classid, i, c, f];
    
    [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Class Details", @"Edit Class", nil] showInView:self.navigationController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Hit Button at: '%d'",buttonIndex);
    //NSLog(@"Button: '%@'",[actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0 && [[actionSheet buttonTitleAtIndex:buttonIndex] isEqual:@"Class Details"]) {
        ClassDetailsViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"classDetailsView"];
        details.classInfo = _infoForRow;
        details.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:details animated:YES];
    } else if (buttonIndex == 1 && [[actionSheet buttonTitleAtIndex:buttonIndex] isEqual:@"Edit Class"]) {
        EditClassViewController *editClass = [self.storyboard instantiateViewControllerWithIdentifier:@"editClass"];
        editClass.classInfo = _infoForRow;
        editClass.delegate = self;
        [self.navigationController pushViewController:editClass animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && _rowtodelete) {
        [managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:_rowtodelete]];
    } else if (buttonIndex == 1 && _updateAvailable) {
        _updateAvailable = FALSE;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://classes.mbilker.us"]];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=http://mbilker.us/apps/agenda-book.plist"]];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Info" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacher == %@", newClass[@"teacher"]];
    [fetchRequest setPredicate:predicate];
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"fetchedObjects: %@", fetchedObjects);
    
    if ([fetchedObjects count] > 0) {
        //NSLog(@"teacher1: '%@', teacher2: '%@'", info.teacher, newClass[@"teacher"]);
        [[[UIAlertView alloc] initWithTitle:@"Other Teacher Exists" message:@"Another Teacher with that name exists in the list"delegate:nil cancelButtonTitle:@"Rename" otherButtonTitles:nil] show];
        return;
    }
    
    Info *info = [NSEntityDescription insertNewObjectForEntityForName:@"Info" inManagedObjectContext:self.managedObjectContext];
    
    info.teacher = newClass[@"teacher"];
    info.subject = newClass[@"subject"];
    info.classid = newClass[@"classid"];
    info.assignments = [NSSet set];
    
    [[Utils instance] saveContext];
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EditClassViewControllerDelegate

- (void)editClassViewControllerDidCancel:(EditClassViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editClassViewController:(EditClassViewController *)controller didChange:(NSDictionary *)info
{
    //NSLog(@"Teacher: '%@'",info[@"teacher"]);
    //NSLog(@"Subject: '%@'",info[@"subject"]);
    //NSLog(@"ClassID: '%@'",info[@"classid"]);
    
    _infoForRow.teacher = info[@"teacher"];
    _infoForRow.subject = info[@"subject"];
    _infoForRow.classid = info[@"classid"];
    
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
            [self configureCell:(SubjectCell *)[tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [[Utils instance] saveContext];
}

#pragma mark - ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd loaded");
    _ready = TRUE;
    
    if (_iAdContainer == nil) {
        _iAdContainer = [[UIView alloc] init];
    }
    
    CGRect frame = banner.frame;
    frame.origin.x = 0;
    frame.origin.y = self.tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - banner.frame.size.height;
    
    [_iAdContainer setFrame:frame];
    [_iAdContainer addSubview:banner];
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        [self.navigationController.view addSubview:_iAdContainer];
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd load error: '%@'",error);
    _ready = FALSE;
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        banner.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [banner removeFromSuperview];
        [_iAdContainer setFrame:CGRectMake(0, 0, 0, 0)];
    }];
    
    NSLog(@"Failed to load: '%@','%@'", error, [error userInfo]);
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    _ready = FALSE;
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        banner.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [banner removeFromSuperview];
        [_iAdContainer setFrame:CGRectMake(0, 0, 0, 0)];
    }];
}

@end
