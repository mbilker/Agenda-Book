
#import "ClassDetailsViewController.h"
#import "Utils.h"

@implementation ClassDetailsViewController

@synthesize teacherName;
@synthesize subjectName;
@synthesize classID;
@synthesize assignmentsCount;
@synthesize doneAssignmentsCount;
@synthesize notDoneAssignmentsCount;

@synthesize classInfo;
@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init ClassDetailsViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc ClassDetailsViewController");
}

- (void)viewDidLoad
{
    self.teacherName.text = [NSString stringWithFormat:@"Teacher: %@",self.classInfo.teacher];
    self.subjectName.text = [NSString stringWithFormat:@"Subject: %@",self.classInfo.subject];
    self.classID.text = [NSString stringWithFormat:@"Class ID: %@",self.classInfo.classid];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Assignment"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacher == %@", self.classInfo];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    int i = 0;
    int c = 0;
    int f = 0;
    for (Assignment *assignment in fetchedObjects) {
        //NSArray *dict = [teacherAssignments objectForKey:[NSString stringWithFormat:@"%d",count]];
        //if ([[dict objectAtIndex:1] boolValue] == TRUE) c++;
        //if ([[dict objectAtIndex:1] boolValue] == FALSE) f++;
        if (assignment.complete) c++;
        if (!assignment.complete) f++;
        i++;
    }
    self.assignmentsCount.text = [NSString stringWithFormat:@"Assignments: %d",i];
    self.doneAssignmentsCount.text = [NSString stringWithFormat:@"Complete Assignments: %d",c];
    self.notDoneAssignmentsCount.text = [NSString stringWithFormat:@"Not Complete Assignments: %d",f];
    
    //NSString *path = [[Functions sharedFunctions] assignmentPath];
    /* if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        NSDictionary *teacherAssignments = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:self.classInfo.teacher];
        
    } else {
        self.assignmentsCount.text = @"Assignments: 0";
        self.doneAssignmentsCount.text = @"Complete Assignments: 0";
        self.notDoneAssignmentsCount.text = @"Not Complete Assignments: 0";
    } */
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

@end
