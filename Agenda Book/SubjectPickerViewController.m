
#import <MagicalRecord/CoreData+MagicalRecord.h>

#import "SubjectPickerViewController.h"
#import "Utils.h"

@implementation SubjectPickerViewController {
    NSUInteger selectedIndex;
}

@synthesize delegate;
@synthesize subject;

@synthesize fetchedResultsController = _fetchedResultsController;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init SubjectPickerViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc SubjectPickerViewController");
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"])
	{
        //NSLog(@"Segue");
		UINavigationController *navigationController = segue.destinationViewController;
		AddSubjectPickerViewController *addSubjectPickerViewController = [navigationController viewControllers][0];
		addSubjectPickerViewController.delegate = self;
	}
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [Subject MR_requestAllSortedBy:@"name" ascending:YES];
    
    [fetchRequest setFetchBatchSize:20];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

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
    id sectionInfo = [_fetchedResultsController sections][0];
    if ([sectionInfo numberOfObjects] <= 0) {
        NSArray *array = @[@"Math", @"Science", @"Social Studies", @"Language Arts", @"Spanish", @"German", @"French", @"Tech Ed", @"Band"];
        for (NSString *sub in array) {
            Subject *subj = [Subject MR_createEntity];
            subj.name = sub;
        }
    }
    
    Subject *info = [Subject MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"name == %@", self.subject]];
    
    //NSLog(@"matched: '%@'",info);
    
    if (info == nil) {
        selectedIndex = -1;
    } else {
        selectedIndex = [_fetchedResultsController indexPathForObject:info].row;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
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
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return [subjects count];
    id sectionInfo = [_fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell index:(NSIndexPath *)indexPath
{
	//cell.textLabel.text = [subjects objectAtIndex:indexPath.row];
    Subject *addedSubject = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = addedSubject.name;
	if (indexPath.row == selectedIndex)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectSubject"];
    [self configureCell:cell index:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Picked: %@ index", indexPath);
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (selectedIndex != NSNotFound)
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	selectedIndex = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	//NSString *theSubject = [subjects objectAtIndex:indexPath.row];
    Subject *theSubject = [_fetchedResultsController objectAtIndexPath:indexPath];
	[self.delegate subjectPickerViewController:self didSelectSubject:theSubject.name];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		//[subjects removeObjectAtIndex:indexPath.row];
        [[NSManagedObjectContext MR_defaultContext] deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        [[Utils instance] saveContext];
		//[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
}

#pragma mark - AddSubjectPickerViewControllerDelegate

- (void)addSubjectPickerViewController:(AddSubjectPickerViewController *)controller subject:(NSString *)newSubject
{
    //NSLog(@"New Subject: %@",newSubject);
    //[subjects addObject:newSubject];
    Subject *addSubject = [Subject MR_createEntity];
    addSubject.name = newSubject;
    [[Utils instance] saveContext];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSubjectPickerViewControllerDidCancel:(AddSubjectPickerViewController *)controller
{
    //NSLog(@"Dismiss");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] index:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [[Utils instance] saveContext];
}

@end
