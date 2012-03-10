
#import "ClassesViewController.h"
#import "Info.h"
#import "SubjectCell.h"

#import <Twitter/Twitter.h>

@implementation ClassesViewController

@synthesize classes;

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

- (void)saveClasses
{
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:20];
    for (int i = 0; i < [self.classes count]; i++)
    {
        Info *details = [self.classes objectAtIndex:i];
        NSLog(@"Teacher: %@, Subject: %@, Complete: %@",details.teacher,details.subject,details.complete ? @"TRUE" : @"FALSE");
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
    self.classes = [subjectsDict valueForKey:@"Classes"];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    /*
	Info *info = [[Info alloc] init];
	info.teacher = @"Mrs. Murray";
	info.subject = @"Math";
	info.complete = TRUE;
	[classes addObject:info];
    
	info = [[Info alloc] init];
	info.teacher = @"Mr. Quenzer";
	info.subject = @"Science";
	info.complete = TRUE;
	[classes addObject:info];
    
	info = [[Info alloc] init];
	info.teacher = @"Ms. Koerper";
	info.subject = @"Social Studies";
	info.complete = FALSE;
	[classes addObject:info];
    
    info = [[Info alloc] init];
	info.teacher = @"Mr. Cullen";
	info.subject = @"Tech Ed";
	info.complete = TRUE;
	[classes addObject:info]; */
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Classes.plist"];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        NSLog(@"File Exists");
        //[self loadClasses];
    }
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		NewClassViewController *newClassViewController = [[navigationController viewControllers] objectAtIndex:0];
		newClassViewController.delegate = self;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.classes count];
}

- (UIImage *)imageForAssignment:(BOOL)complete
{
    //NSLog(@"Selection: %@", (complete ? @"TRUE" : @"FALSE"));
	switch (complete)
	{
        case FALSE: return [UIImage imageNamed:@"X.png"];
        case TRUE: return [UIImage imageNamed:@"Checkmark.png"];
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SubjectCell *cell = (SubjectCell *)[tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
	Info *info = [self.classes objectAtIndex:indexPath.row];
	cell.nameLabel.text = info.teacher;
	cell.gameLabel.text = info.subject;
	cell.assignmentsImageView.image = [self imageForAssignment:info.complete];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.classes removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            NSLog(@"FOUND");
            return;
        } else {
            NSLog(@"Not found at index %d, string1 %@, string2 %@",i,info.teacher,newClass.teacher);
        }
    }
    [self saveClasses];
    [self.classes addObject:newClass];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.classes count] - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
