#import "Functions.h"

@implementation Functions

+ (NSString *)assignmentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Assignments.plist"];
    return path;
}

+ (NSString *)classPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Classes.plist"];
    return path;
}

+ (NSString *)subjectPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Subjects.plist"];
    return path;
}

+ (UIColor *)colorForComplete:(BOOL)complete
{
    //NSLog(@"Selection: %@", (complete ? @"TRUE" : @"FALSE"));
	switch (complete)
	{
        case FALSE: return [UIColor colorWithRed:1 green:.5 blue:0.5 alpha:0.5];
        case TRUE: return [UIColor colorWithRed:.5 green:1 blue:.5 alpha:0.5];
	}
	return nil;
}

+ (UIColor *)determineClassComplete:(NSString *)string
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
}

@end
