//
//  PlayerDetailsViewController.m
//  Agenda Book
//
//  Created by Matt Bilker on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubjectViewController.h"
#import "Player.h"

@implementation SubjectViewController
{
	NSString *subject;
}

@synthesize delegate;
@synthesize teacherTextField;
@synthesize detailLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init SubjectViewController");
		subject = @"Science";
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc SubjectViewController");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PickSubject"])
	{
        NSLog(@"Segue");
		SubjectPickerViewController *subjectPickerViewController = segue.destinationViewController;
		subjectPickerViewController.delegate = self;
		subjectPickerViewController.subject = subject;
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.detailLabel.text = subject;
}

- (void)viewDidUnload
{
    [self setTeacherTextField:nil];
    [self setDetailLabel:nil];
    [self setDetailLabel:nil];
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

- (IBAction)cancel:(id)sender
{
	[self.delegate subjectViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    if ([self.teacherTextField hasText]) {
        Player *player = [[Player alloc] init];
        player.name = self.teacherTextField.text;
        player.game = subject;
        player.complete = TRUE;
        [self.delegate subjectViewController:self didAddPlayer:player];
    } else {
        NSLog(@"Empty");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0)
		[self.teacherTextField becomeFirstResponder];
}

#pragma mark - SubjectPickerViewControllerDelegate

- (void)subjectPickerViewController:(SubjectPickerViewController *)controller didSelectGame:(NSString *)theSubject
{
    NSLog(@"Ran");
	subject = theSubject;
	self.detailLabel.text = subject;
	[self.navigationController popViewControllerAnimated:YES];
}

@end
