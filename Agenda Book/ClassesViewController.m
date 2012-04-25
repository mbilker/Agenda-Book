
#import "ClassesViewController.h"
#import "AssignmentsViewController.h"
#import "DetailsViewController.h"
#import "EditClassViewController.h"

#import "Info.h"
#import "SubjectCell.h"
#import "Functions.h"
#import "CustomAlert.h"

#import <Twitter/Twitter.h>

@implementation ClassesViewController {
    NSMutableArray *_assignments;
    NSIndexPath *_rowtodelete;
    Info *infoForRow;
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
        [tempDict setObject:[NSArray arrayWithObjects:details.teacher,details.subject,details.classid, nil] forKey:[NSString stringWithFormat:@"%d",i]];
    }
    [tempDict writeToFile:[Functions classPath] atomically:YES];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"iCloud"] == 1) {
        NSURL *classesCloud = [Functions classiCloud];
        [tempDict writeToURL:classesCloud atomically:YES];
    }
    //NSLog(@"Classes array: %@", tempDict);
}

- (void)loadClasses
{
    NSMutableDictionary *subjectsDict = [NSMutableDictionary dictionaryWithContentsOfFile:[Functions classPath]];
    for (int i = 0; i < [subjectsDict count]; i++)
    {
        NSArray *tempArray = [subjectsDict objectForKey:[NSString stringWithFormat:@"%d",i]];
        Info *info = [[Info alloc] init];
        info.teacher = [tempArray objectAtIndex:0];
        info.subject = [tempArray objectAtIndex:1];
        info.classid = [tempArray objectAtIndex:2];
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
    if ([[NSFileManager alloc] fileExistsAtPath:[Functions classPath]]) {
        //NSLog(@"File Exists");
        [self loadClasses];
    }
    
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
        int d = 0;
        for (Info *i in self.classes) {
            if ([Functions determineClassComplete:i.teacher]) {
                d++;
            }
            //NSLog(@"Teacher: '%@', Complete: '%@'",i.teacher,[Functions determineClassComplete:i.teacher] ? @"YES" : @"NO");
        }
        NSString *s;
        if (!([self.classes count] == 1)) {
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
        [tweetSheet setInitialText:[NSString stringWithFormat:@"I'm using @mbilker's agenda book app for @TheQuenz. I have %d %@. Homework for %d %@ is complete.",[self.classes count],s,d,f]];
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

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SubjectCell *cell = (SubjectCell *)[tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
	Info *info = [self.classes objectAtIndex:indexPath.row];
	cell.nameLabel.text = info.teacher;
	cell.gameLabel.text = info.subject;
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.backgroundColor = [Functions determineClassComplete:info.teacher];
    cell.backgroundView = backgroundView;
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Accessory tapped");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Teacher" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Class Details", @"Edit Class", nil];
    infoForRow = [self.classes objectAtIndex:indexPath.row];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Hit Button at: '%d'",buttonIndex);
    //NSLog(@"Button: '%@'",[actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex == 0 && [actionSheet buttonTitleAtIndex:buttonIndex] == @"Class Details") {
        //NSLog(@"Class Details Hit");
        DetailsViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"detailsView"];
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
        [self.classes removeObjectAtIndex:_rowtodelete.row];
        [self saveClasses];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_rowtodelete] withRowAnimation:UITableViewRowAnimationFade];
    }
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
    NSString *path = [Functions assignmentPath];
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

@end
