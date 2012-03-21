
#import "ClassesViewController.h"
#import "Info.h"
#import "SubjectCell.h"
#import "AssignmentsViewController.h"

#import <Twitter/Twitter.h>

@implementation ClassesViewController {
    NSMutableArray *_assignments;
}

@synthesize classes;
@synthesize editButton;

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

- (BOOL)checkIfExists:(Info *)info
{
    for (int i = 0; i < [self.classes count]; i++)
    {
        Info *currentClass = [self.classes objectAtIndex:i];
        if ([info.teacher isEqual:currentClass.teacher]) {
            //NSLog(@"Found %@ already exists",info.teacher);
            return YES;
        }
    }
    return NO;
}

- (void)saveClasses
{
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:20];
    for (int i = 0; i < [self.classes count]; i++)
    {
        Info *details = [self.classes objectAtIndex:i];
        //NSLog(@"Teacher: %@, Subject: %@, Complete: %@",details.teacher,details.subject,details.complete ? @"TRUE" : @"FALSE");
        [tempDict setObject:[NSArray arrayWithObjects:details.teacher,details.subject,[NSNumber numberWithBool:details.complete], nil] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Classes.plist"];
    [tempDict writeToFile:path atomically:YES];
    //NSLog(@"Classes array: %@", tempDict);
}

- (void)loadClasses
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Classes.plist"];
    NSMutableDictionary *subjectsDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    for (int i = 0; i < [subjectsDict count]; i++)
    {
        NSArray *tempArray = [subjectsDict objectForKey:[NSString stringWithFormat:@"%d",i]];
        Info *info = [[Info alloc] init];
        info.teacher = [tempArray objectAtIndex:0];
        info.subject = [tempArray objectAtIndex:1];
        info.complete = [[tempArray objectAtIndex:2] boolValue];
        //NSLog(@"Teacher: %@, Subject: %@, Complete: %@",info.teacher,info.subject,info.complete ? @"TRUE" : @"FALSE");
        if (![self checkIfExists:info]) {
            [self.classes addObject:info];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.classes count] - 1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
    //self.classes = [subjectsDict valueForKey:@"Classes"];
}

#pragma mark - View lifecycle

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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Classes.plist"];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        //NSLog(@"File Exists");
        [self loadClasses];
    }
    
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
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		NewClassViewController *newClassViewController = [[navigationController viewControllers] objectAtIndex:0];
		newClassViewController.delegate = self;
	} else if ([segue.identifier isEqualToString:@"ShowAssignments"])
    {
        Info *i = [self.classes objectAtIndex:[[self.tableView indexPathForCell:sender] row]];
        //NSLog(@"Moving Teacher: %@, Subject: %@, Complete: %@",i.teacher,i.subject,i.complete ? @"TRUE" : @"FALSE");
        _assignments = [NSMutableArray arrayWithCapacity:20];
        AssignmentsViewController *assignmentsViewController = segue.destinationViewController;
        assignmentsViewController.assignments = _assignments;
        assignmentsViewController.info = i;
    }
}

- (IBAction)tweet:(id)sender
{
    if ([TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        [tweetSheet setInitialText:[NSString stringWithFormat:@"I'm using @mbilker's agenda book app for @TheQuenz. I have %d subjects.",[self.classes count]]];
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
	return [self.classes count];
}

- (UIColor *)colorForAssignment:(BOOL)complete
{
    //NSLog(@"Selection: %@", (complete ? @"TRUE" : @"FALSE"));
	switch (complete)
	{
        case FALSE: return [UIColor colorWithRed:1 green:.5 blue:0.5 alpha:0.5];
        case TRUE: return [UIColor colorWithRed:.5 green:1 blue:.5 alpha:0.5];
	}
	return nil;
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SubjectCell *cell = (SubjectCell *)[tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
	Info *info = [self.classes objectAtIndex:indexPath.row];
	cell.nameLabel.text = info.teacher;
	cell.gameLabel.text = info.subject;
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [self colorForAssignment:info.complete];
    cell.backgroundView = backgroundView;
    /* for ( UIView* view in cell.contentView.subviews ) 
    {
        view.backgroundColor = [ UIColor clearColor ];
    } */

    //cell.contentView.backgroundColor = [self colorForAssignment:info.complete];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.classes removeObjectAtIndex:indexPath.row];
        [self saveClasses];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //_transferInfo = [self.classes objectAtIndex:indexPath.row];
    //NSLog(@"Moving Teacher: %@, Subject: %@, Complete: %@",_transferInfo.teacher,_transferInfo.subject,_transferInfo.complete ? @"TRUE" : @"FALSE");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{    
    Info *classToMove = [self.classes objectAtIndex:sourceIndexPath.row];
    //NSLog(@"Moving Teacher: %@, Subject: %@, Complete: %@",classToMove.teacher,classToMove.subject,classToMove.complete ? @"TRUE" : @"FALSE");
    [self.classes removeObjectAtIndex:sourceIndexPath.row];
    [self.classes insertObject:classToMove atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
    //NSLog(@"End");
    [self saveClasses];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}

#pragma mark - PlayerDetailsViewControllerDelegate

- (void)newClassViewControllerDidCancel:(ClassesViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)newClassViewController:(ClassesViewController *)controller didAddInfo:(Info *)newClass
{
    for (int i = 0; i < [self.classes count]; i++) {
        Info *info = [self.classes objectAtIndex:i];
        if ([info.teacher isEqual:newClass.teacher]) {
            [[[UIAlertView alloc] initWithTitle:@"Other Teacher Exists" message:@"Another Teacher with that name exists in the list" delegate:self cancelButtonTitle:@"Rename" otherButtonTitles:nil] show];
            //NSLog(@"FOUND");
            return;
        }
    }
    [self.classes addObject:newClass];
    [self saveClasses];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.classes count] - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
