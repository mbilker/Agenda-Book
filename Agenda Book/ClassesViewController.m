
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

#define WILL_DISPLAY_ADS

@implementation ClassesViewController {
    NSIndexPath *_rowtodelete;
    BOOL _updateAvailable;
    Info *infoForRow;
}

@synthesize editButton;
@synthesize managedObjectContext;
//@synthesize classes;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize iAdBanner;

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
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"subject" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
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

- (void)requestDone:(TKHTTPRequest *)arg1
{
    NSError *error;
    NSDictionary *update = [NSJSONSerialization JSONObjectWithData:arg1.responseData options:kNilOptions error:&error];
    int appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue];
    int updateVersion = [[update valueForKey:@"version"] intValue];
    //NSLog(@"version: '%d', version: '%d'",appVersion,updateVersion);
    if (updateVersion > appVersion) {
        _updateAvailable = TRUE;
        [[[UIAlertView alloc] initWithTitle:@"Newer App Version" message:[NSString stringWithFormat:@"There is a newer app version (%d), you currently have %d",updateVersion,appVersion] delegate:self cancelButtonTitle:@"Ignore" otherButtonTitles:@"Update", nil] show];
        //NSLog(@"newer app version available");
    }
}

- (void)checkUpdate
{
    _updateAvailable = FALSE;
    TKHTTPRequest *request = [TKHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/update",server]]];
    request.delegate = self;
    request.didFinishSelector = @selector(requestDone:);
    [request start];
}

#ifdef WILL_DISPLAY_ADS
- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.iAdBanner removeFromSuperview];
}

- (void)fixupAdView {
    //NSLog(@"superview: '%@'",self.iAdBanner.superview);
    //[UIView beginAnimations:@"fixupViews" context:nil];
    if (self.iAdBanner.superview == nil) {
        //NSLog(@"iAd is not shown");
        [self.navigationController.view addSubview:self.iAdBanner];
        [self.iAdBanner setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize adSize = [self.iAdBanner sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height, adSize.width, adSize.height);
        self.iAdBanner.frame = startRect;
        
        // compute the end frame
        CGRect adRect = CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - self.navigationController.toolbar.frame.size.height - adSize.height, adSize.width, adSize.height);
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.iAdBanner.frame = adRect;
        
        // shrink the table vertical size to make room for the ad
        /* CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.iAdBanner.frame.size.height;
        self.tableView.frame = newFrame; */
        [UIView commitAnimations];
    }
    //[UIView commitAnimations];
}

- (void)hideAd
{
    //NSLog(@"superview: '%@'",self.iAdBanner.superview);
    if (self.iAdBanner.superview != nil) {
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.iAdBanner.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
    
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    
        self.iAdBanner.frame = endFrame;
        [UIView commitAnimations];
    
        // grow the table back again in vertical size to make room for the ad
        /* CGRect newFrame = self.tableView.frame;
        newFrame.size.height += self.iAdBanner.frame.size.height;
        self.tableView.frame = newFrame; */
    }
}
#endif

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkUpdate];
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
#ifndef WILL_DISPLAY_ADS
    iAdBanner = nil;
    //NSLog(@"No ads");
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
#ifdef WILL_DISPLAY_ADS
    [self hideAd];
#endif
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
            if ([[Functions sharedFunctions] determineClassComplete:i.teacher context:self.managedObjectContext]) {
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
    backgroundView.backgroundColor = [[Functions sharedFunctions] determineClassComplete:info.teacher context:self.managedObjectContext];
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
        //[[Functions sharedFunctions] saveContext:self.managedObjectContext];
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
        details.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:details animated:YES];
    } else if (buttonIndex == 1 && [actionSheet buttonTitleAtIndex:buttonIndex] == @"Edit Class") {
        EditClassViewController *editClass = [self.storyboard instantiateViewControllerWithIdentifier:@"editClass"];
        editClass.classInfo = infoForRow;
        editClass.delegate = self;
        editClass.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:editClass animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //NSLog(@"ButtonIndex: '%d'",buttonIndex);
    if (buttonIndex == 1 && _rowtodelete) {
        //[self.classes removeObjectAtIndex:_rowtodelete.row];
        [managedObjectContext deleteObject:[_fetchedResultsController objectAtIndexPath:_rowtodelete]];
		//[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_rowtodelete] withRowAnimation:UITableViewRowAnimationFade];
    } else if (buttonIndex == 1 && _updateAvailable) {
        _updateAvailable = FALSE;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mbilker.us/agenda.html"]];
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
    [[Functions sharedFunctions] saveContext:self.managedObjectContext];
	//NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.classes count] - 1 inSection:0];
	//[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - EditClassViewControllerDelegate

- (void)editClassViewControllerDidCancel:(EditClassViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editClassViewController:(EditClassViewController *)controller didChange:(NSDictionary *)info
{
    //NSLog(@"Teacher: '%@'",info.teacher);
    //NSLog(@"Subject: '%@'",info.subject);
    //NSLog(@"Class ID: '%@'",info.classid);
    /* NSString *path = [[Functions sharedFunctions] assignmentPath];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        //NSLog(@"File Exists");
        NSMutableDictionary *teachersDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        NSArray *teacherAssignments = [teachersDict objectForKey:infoForRow.teacher];
        if (teacherAssignments != nil) {
            [teachersDict removeObjectForKey:infoForRow.teacher];
            [teachersDict setObject:teacherAssignments forKey:info.teacher];
            [teachersDict writeToFile:path atomically:YES];
        }
    } */
    //infoForRow.teacher = info.teacher;
    //infoForRow.subject = info.subject;
    //infoForRow.classid = info.classid;
    infoForRow.teacher = [info valueForKey:@"teacher"];
    infoForRow.subject = [info valueForKey:@"subject"];
    infoForRow.classid = [info valueForKey:@"classid"];
    [[Functions sharedFunctions] saveContext:self.managedObjectContext];
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

#ifdef WILL_DISPLAY_ADS
#pragma mark ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //NSLog(@"iAd loaded");
    [self fixupAdView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //NSLog(@"iAd load error: '%@'",error);
    [self hideAd];
    //NSLog(@"Failed to load: '%@','%@'",error,[error userInfo]);
}
#endif

@end
