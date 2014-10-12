
#import <Social/Social.h>

#import <POP/POP.h>
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>

#import "ClassesViewController.h"
#import "AssignmentsViewController.h"
#import "SubjectCell.h"

#import "Assignment.h"
#import "Info.h"

#import "Utils.h"

#import "Constants.h"

@implementation ClassesViewController {
    NSIndexPath *_rowToDelete;
    
    BOOL _updateAvailable;
    BOOL _updateChecked;
    BOOL _ready;
    
    Info *_infoForRow;
    
    UIView *_iAdContainer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        NSLog(@"init %@", [self class]);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", [self class]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [Info MR_requestAllSortedBy:@"subject" ascending:NO];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:@"AgendaCache_Classes"];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)reloadFetchedResults:(NSNotification*)note {
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        [MagicalRecord handleErrors:error];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFetchedResults:) name:kRefreshAllViews object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[Utils instance] initializeNavigationController:self.navigationController];
    
    [self reloadFetchedResults:nil];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"]) {
		UINavigationController *navigationController = segue.destinationViewController;
        [[Utils instance] initializeNavigationController:navigationController];
		NewClassViewController *newClassViewController = [navigationController viewControllers][0];
		newClassViewController.delegate = self;
        NSLog(@"viewController: %@",newClassViewController);
	} else if ([segue.identifier isEqualToString:@"ShowAssignments"]) {
        Info *i = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        AssignmentsViewController *assignmentsViewController = segue.destinationViewController;
        assignmentsViewController.info = i;
    }
}

- (IBAction)tweet:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        int d = 0;
        for (Info *i in self.fetchedResultsController.fetchedObjects) {
            if ([[Utils instance] determineClassComplete:i]) {
                d++;
            }
            NSLog(@"Teacher: '%@', Complete: '%@'", i.teacher, [[Utils instance] determineClassComplete:i] ? @"YES" : @"NO");
        }
        
        NSString *s = ([self.fetchedResultsController.fetchedObjects count] != 1) ? @"classes" : @"class";
        NSString *f = (d != 1) ? @"classes" : @"class";
        unsigned long length = [self.fetchedResultsController.fetchedObjects count];
        
        [twitter setInitialText:[NSString stringWithFormat:@"I'm using @mbilker's agenda book app for @TheQuenz. I have %lu %@. Homework for %d %@ is complete.", length, s, d, f]];
	    [self presentViewController:twitter animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"No Twitter" message:@"Twitter is not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)menuButtonPressed:(id)sender
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    [dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//return [self.classes count];
    if ([self.fetchedResultsController.sections count] == 0) {
        return 0;
    } else {
        id sectionInfo = [self.fetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
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
        
        _rowToDelete = indexPath;
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
    
    unsigned long completed = [Assignment MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"teacher == %@ AND complete == 1", _infoForRow]];
    unsigned long all = [Assignment MR_countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"teacher == %@", _infoForRow]];
    unsigned long incomplete = all - completed;
    
    NSString *title = [NSString stringWithFormat:@"Teacher: %@\nSubject: %@\nID: %@\n\nAssignments: %lu\nComplete Assignments: %lu\nIncomplete Assignments: %lu", _infoForRow.teacher, _infoForRow.subject, _infoForRow.classid, all, completed, incomplete];
    
    [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Class", nil] showInView:self.navigationController.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && [[actionSheet buttonTitleAtIndex:buttonIndex] isEqual:@"Edit Class"]) {
        EditClassViewController *editClass = [self.storyboard instantiateViewControllerWithIdentifier:@"editClass"];
        editClass.classInfo = _infoForRow;
        editClass.delegate = self;
        [self.navigationController pushViewController:editClass animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && _rowToDelete) {
        [[NSManagedObjectContext MR_defaultContext] deleteObject:[self.fetchedResultsController objectAtIndexPath:_rowToDelete]];
    } else if (buttonIndex == 1 && _updateAvailable) {
        _updateAvailable = FALSE;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://classes.mbilker.us"]];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=http://mbilker.us/apps/agenda-book.plist"]];
    }
}

#pragma mark - NewClassViewControllerDelegate

- (void)newClassViewControllerDidCancel:(NewClassViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newClassViewController:(NewClassViewController *)controller didAddInfo:(NSDictionary *)newClass
{
    NSArray *fetchedObjects = [Info MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"teacher == %@", newClass[@"teacher"]]];
    
    NSLog(@"fetchedObjects: %@", fetchedObjects);
    
    if ([fetchedObjects count] > 0) {
        //NSLog(@"teacher1: '%@', teacher2: '%@'", info.teacher, newClass[@"teacher"]);
        [[[UIAlertView alloc] initWithTitle:@"Other Teacher Exists" message:@"Another Teacher with that name exists in the list"delegate:nil cancelButtonTitle:@"Rename" otherButtonTitles:nil] show];
        return;
    }
    
    Info *info = [Info MR_createEntity];
    
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
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(SubjectCell *)[tableView cellForRowAtIndexPath:indexPath] indexPath:indexPath];
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
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [[Utils instance] saveContext];
}

#pragma mark - ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    _ready = TRUE;
    
    if (_iAdContainer == nil) {
        _iAdContainer = [[UIView alloc] init];
    }
    
    CGRect frame = banner.frame;
    frame.origin.x = 0;
    frame.origin.y = self.navigationController.toolbar.frame.origin.y - banner.frame.size.height;
    
    [_iAdContainer setFrame:frame];
    [_iAdContainer addSubview:banner];
    
    _iAdContainer.layer.borderColor = [UIColor blackColor].CGColor;
    _iAdContainer.layer.borderWidth = 0.5f;
    
    [UIView animateWithDuration:0.5f animations:^(void) {
        [self.navigationController.view addSubview:_iAdContainer];
    }];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
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
    
    POPDecayAnimation *anim = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerTranslationY];
    //anim.fromValue = @(banner.layer.position.y);
    //anim.toValue = @([UIScreen mainScreen].bounds.origin.y + [UIScreen mainScreen].bounds.size.height + banner.frame.size.height + 5);
    anim.velocity = @(750.0f);
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        [banner removeFromSuperview];
    };
    [_iAdContainer.layer pop_addAnimation:anim forKey:@"finishedTranslateOffscreen"];
}

@end
