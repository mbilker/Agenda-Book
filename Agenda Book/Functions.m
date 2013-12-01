
#import "Functions.h"

@implementation Functions

static Functions *instanceOfFunctions;

+ (id)alloc
{
    @synchronized(self)
    {
        NSAssert(instanceOfFunctions == nil, @"Attempted to allocate a second instance of the singleton: Functions");
        instanceOfFunctions = [super alloc];
        return instanceOfFunctions;
    }
    
    return nil;
}

+ (Functions *)sharedFunctions
{
    @synchronized(self)
    {
        if (instanceOfFunctions == nil)
        {
            (void)[[Functions alloc] init];
        }
        
        return instanceOfFunctions;
    }
    
    return nil;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog(@"init Functions");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc Functions");
}

- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (NSDate *)dateWithOutTime:(NSDate *)datDate
{
    if (datDate == nil) {
        datDate = [NSDate date];
    }
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:datDate];
    return [calendar dateFromComponents:comps];
}

/* - (NSString *)assignmentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Assignments.plist"];
    return path;
}

- (NSString *)classPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Classes.plist"];
    return path;
}

- (NSString *)subjectPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Subjects.plist"];
    return path;
}

- (NSURL *)assignmentiCloud
{
    NSURL *classesCloud = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:@"DXD4278H9V.us.mbilker.agendabook"];
    NSURL *ubiquitousPackage = [[classesCloud URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"Assignments.plist"];
    return ubiquitousPackage;
}

- (NSURL *)classiCloud
{
    NSURL *classesCloud = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:@"DXD4278H9V.us.mbilker.agendabook"];
    NSURL *ubiquitousPackage = [[classesCloud URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"Classes.plist"];
    return ubiquitousPackage;
}

- (NSURL *)subjectiCloud
{
    NSURL *classesCloud = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:@"DXD4278H9V.us.mbilker.agendabook"];
    NSURL *ubiquitousPackage = [[classesCloud URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:@"Subjects.plist"];
    return ubiquitousPackage;
} */

- (UIColor *)colorForComplete:(BOOL)complete
{
    //NSLog(@"Selection: %@", (complete ? @"TRUE" : @"FALSE"));
	switch (complete)
	{
        case FALSE: return [UIColor colorWithRed:1 green:.5 blue:0.5 alpha:0.5];
        case TRUE: return [UIColor colorWithRed:.5 green:1 blue:.5 alpha:0.5];
	}
	return nil;
}

/* - (UIColor *)determineClassComplete:(NSString *)string
{
    NSString *path = [self assignmentPath];
    if ([[NSFileManager alloc] fileExistsAtPath:path]) {
        NSDictionary *subjectsD = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:string];
        //NSLog(@"Assignments: '%@'",subjectsD);
        for (int i = 0; i < [subjectsD count]; i++) {
            NSArray *a = [subjectsD objectForKey:[[NSNumber numberWithInt:i] stringValue]];
            //NSLog(@"1: '%@' 2: '%@'",[a objectAtIndex:0],[[a objectAtIndex:1] boolValue] ? @"YES" : @"NO");
            if ([[a objectAtIndex:1] boolValue] == FALSE) return [self colorForComplete:FALSE];
        }
    }
    return [self colorForComplete:TRUE];
} */

- (UIColor *)determineClassComplete:(NSString *)string context:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Assignment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K == %@)",@"teacher",string];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (Assignment *assignment in fetchedObjects) {
        if (!assignment.complete) return [self colorForComplete:FALSE]; 
    }
    return [self colorForComplete:TRUE];
}

- (void)saveContext:(NSManagedObjectContext *)context
{
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

@end
