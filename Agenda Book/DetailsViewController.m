
#import "DetailsViewController.h"
#import "Functions.h"

@implementation DetailsViewController

@synthesize teacherName;
@synthesize subjectName;
@synthesize classID;
@synthesize assignmentsCount;
@synthesize doneAssignmentsCount;
@synthesize notDoneAssignmentsCount;

@synthesize classInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init DetailsViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc DetailsViewController");
}

- (void)viewDidLoad
{
    self.teacherName.text = [NSString stringWithFormat:@"Teacher: %@",self.classInfo.teacher];
    self.subjectName.text = [NSString stringWithFormat:@"Subject: %@",self.classInfo.subject];
    self.classID.text = [NSString stringWithFormat:@"Class ID: %@",self.classInfo.classid];
    
    NSString *path = [Functions assignmentPath];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        NSDictionary *teacherAssignments = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:self.classInfo.teacher];
        int i = 0;
        int c = 0;
        int f = 0;
        for (int count = 0; i < [teacherAssignments count]; count++) {
            NSArray *dict = [teacherAssignments objectForKey:[NSString stringWithFormat:@"%d",count]];
            if ([[dict objectAtIndex:1] boolValue] == TRUE) c++;
            if ([[dict objectAtIndex:1] boolValue] == FALSE) f++;
            i++;
        }
        self.assignmentsCount.text = [NSString stringWithFormat:@"Assignments: %d",i];
        self.doneAssignmentsCount.text = [NSString stringWithFormat:@"Complete Assignments: %d",c];
        self.notDoneAssignmentsCount.text = [NSString stringWithFormat:@"Not Complete Assignments: %d",f];
    } else {
        self.assignmentsCount.text = @"Assignments: 0";
        self.doneAssignmentsCount.text = @"Complete Assignments: 0";
        self.notDoneAssignmentsCount.text = @"Not Complete Assignments: 0";
    }
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
