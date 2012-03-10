//
//  GamePickerViewController.m
//  Agenda Book
//
//  Created by Matt Bilker on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubjectPickerViewController.h"

@implementation SubjectPickerViewController
{
	NSMutableArray *subjects;
	NSUInteger selectedIndex;
}
@synthesize delegate;
@synthesize subject;

- (id)initWithCoder:(NSCoder *)aDecoder
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"AddSubject"])
	{
        //NSLog(@"Segue");
		UINavigationController *navigationController = segue.destinationViewController;
		AddSubjectPickerViewController *addSubjectPickerViewController = [[navigationController viewControllers] objectAtIndex:0];
		addSubjectPickerViewController.delegate = self;
	}
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

- (void)saveSubjects
{
    NSDictionary *subjectsDict = [NSDictionary dictionaryWithObject:subjects forKey:@"Subjects"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Subjects.plist"];
    [subjectsDict writeToFile:path atomically:YES];
    //NSLog(@"Subjects array: %@", subjectsDict);
}

- (void)loadSubjects
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Subjects.plist"];
    NSMutableDictionary *subjectsDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    subjects = [subjectsDict valueForKey:@"Subjects"];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    subjects = [NSMutableArray arrayWithObjects:@"Math",@"Science",@"Social Studies",@"Language Arts",@"Spanish",@"German",@"French",@"Tech Ed",nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Subjects.plist"];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        //NSLog(@"File Exists");
        [self loadSubjects];
    } else {
        [self saveSubjects];
    }
    
    selectedIndex = [subjects indexOfObject:self.subject];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    subjects = nil;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [subjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubjectCell"];
	cell.textLabel.text = [subjects objectAtIndex:indexPath.row];
	if (indexPath.row == selectedIndex)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
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
	NSString *theSubject = [subjects objectAtIndex:indexPath.row];
	[self.delegate subjectPickerViewController:self didSelectSubject:theSubject];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[subjects removeObjectAtIndex:indexPath.row];
        [self saveSubjects];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}   
}

#pragma mark - AddSubjectPickerViewControllerDelegate

- (void)addSubjectPickerViewController:(AddSubjectPickerViewController *)controller subject:(NSString *)newSubject
{
    //NSLog(@"New Subject: %@",newSubject);
    [subjects addObject:newSubject];
    [self saveSubjects];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[subjects count] - 1 inSection:0];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSubjectPickerViewControllerDidCancel:(AddSubjectPickerViewController *)controller
{
    //NSLog(@"Dismiss");
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
