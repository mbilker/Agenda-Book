
#import "ClassesViewController.h"
#import "Player.h"
#import "SubjectCell.h"

@implementation ClassesViewController

@synthesize players;

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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"])
	{
		UINavigationController *navigationController = segue.destinationViewController;
		SubjectViewController *subjectViewController = [[navigationController viewControllers] objectAtIndex:0];
		subjectViewController.delegate = self;
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.players count];
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
    NSLog(@"Row: %d",indexPath.row);
	SubjectCell *cell = (SubjectCell *)[tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
	Player *player = [self.players objectAtIndex:indexPath.row];
	cell.nameLabel.text = player.name;
	cell.gameLabel.text = player.game;
	cell.assignmentsImageView.image = [self imageForAssignment:player.complete];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.players removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PlayerDetailsViewControllerDelegate

- (void)subjectViewControllerDidCancel:(ClassesViewController *)controller
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)subjectViewController:(ClassesViewController *)controller didAddPlayer:(Player *)player
{
	[self.players addObject:player];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.players count] - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
