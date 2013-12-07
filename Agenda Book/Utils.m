
#import "Utils.h"

@implementation Utils

static Utils *_instance;

+ (id)alloc
{
    @synchronized(self) {
        NSAssert(_instance == nil, @"Attempted to allocate a second instance of the singleton: Functions");
        _instance = [super alloc];
        return _instance;
    }
    
    return nil;
}

+ (Utils *)instance
{
    if (_instance != nil) {
        return _instance;
    }
    
    @synchronized(self) {
        (void)[[Utils alloc] init];
        
        return _instance;
    }
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

- (BOOL)determineClassComplete:(Info *)info
{
    for (Assignment *assignment in info.assignments) {
        if (!assignment.complete) return FALSE;
    }
    
    return TRUE;
}

- (UIColor *)determineClassCompleteColor:(Info *)info
{
    return [self colorForComplete:[self determineClassComplete:info]];
}

- (void)saveContext
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate saveContext];
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

- (NSManagedObjectContext *)managedObjectContext
{
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
}

@end
