#import "Assignment.h"
#import "Info.h"
#import "Utils.h"

@implementation Assignment

@dynamic assignmentText;
@dynamic complete;
@dynamic dueDate;

@dynamic teacher;

- (instancetype)initUsingDefaultContext
{
    return [[Assignment alloc] initWithEntity:[NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:[[Utils instance] managedObjectContext]] insertIntoManagedObjectContext:[[Utils instance] managedObjectContext]];
}

@end
