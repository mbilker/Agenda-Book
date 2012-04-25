//
//  PlayerDetailsViewController.m
//  Agenda Book
//
//  Created by Matt Bilker on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewClassViewController.h"
#import "Info.h"

@implementation NewClassViewController
{
	NSString *subject;
    NSString *tableClassID;
}

@synthesize delegate;
@synthesize teacherTextField;
@synthesize detailLabel;
@synthesize classIDLabel;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init NewClassViewController");
		subject = @"Not Chosen";
        tableClassID = @"0";
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc NewClassViewController");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PickSubject"])
	{
        //NSLog(@"Segue");
		SubjectPickerViewController *subjectPickerViewController = segue.destinationViewController;
		subjectPickerViewController.delegate = self;
		subjectPickerViewController.subject = subject;
	}
    if ([segue.identifier isEqualToString:@"setClassID"])
	{
        //NSLog(@"Segue");
		ClassIDViewController *classIDPickerViewController = segue.destinationViewController;
		classIDPickerViewController.delegate = self;
		//classIDPickerViewController.enteredClassID = tableClassID;
	}
}

- (id)initWithStyle:(UITableViewStyle)style
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	self.detailLabel.text = subject;
    self.classIDLabel.text = tableClassID;
    [super viewDidLoad];
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
    [self.teacherTextField becomeFirstResponder];
    self.teacherTextField.delegate = self;
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
    return YES;
}

- (IBAction)cancel:(id)sender
{
	[self.delegate newClassViewControllerDidCancel:self];
}

- (void)checkDone
{
    if ([self.teacherTextField hasText] && subject != @"Not Chosen") {
        Info *info = [[Info alloc] init];
        info.teacher = self.teacherTextField.text;
        info.subject = subject;
        info.classid = tableClassID;
        //NSLog(@"ClassID: '%@'",info.classid);
        [self.delegate newClassViewController:self didAddInfo:info];
    } else {
        //NSLog(@"Empty and did not choose subject");
        [[[UIAlertView alloc] initWithTitle:@"Selection not complete" message:@"You did not fill in the teacher or select a subject" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    //NSLog(@"Done button hit");
    [self checkDone];
    return NO;
}

- (IBAction)done:(id)sender
{
    [self checkDone];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == 0)
		[self.teacherTextField becomeFirstResponder];
}

#pragma mark - SubjectPickerViewControllerDelegate

- (void)subjectPickerViewController:(SubjectPickerViewController *)controller didSelectSubject:(NSString *)theSubject
{
	subject = theSubject;
	self.detailLabel.text = subject;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ClassIDViewControllerDelegate

- (void)classIDViewControllerDidCancel:(ClassIDViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)classIDViewController:(ClassIDViewController *)controller didAddClassID:(NSString *)classID
{
    tableClassID = classID;
    self.classIDLabel.text = tableClassID;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
