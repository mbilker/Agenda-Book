
#import <QuartzCore/QuartzCore.h>

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <POP/POP.h>

#import "Utils.h"

#import "Assignment.h"
#import "Info.h"

#import "Constants.h"

@implementation Utils
{
    NSDateFormatter *_GmtDateFormatter;
}

static Utils *_instance;

+ (id)alloc
{
    @synchronized(self) {
        NSAssert(_instance == nil, @"Attempted to allocate a second instance of the singleton: Utils");
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
        NSLog(@"init Utils");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc Utils");
}

- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void)initializeNavigationController:(UINavigationController *)navigationController
{
    navigationController.navigationBar.translucent = NO;
    navigationController.toolbar.translucent = NO;
    
    if (navigationController.navigationBar.barTintColor == nil) {
        navigationController.navigationBar.barTintColor = kBarTintColor;
    }
    
    if (navigationController.toolbar.barTintColor == nil) {
        navigationController.toolbar.barTintColor = kBarTintColor;
    }
    
    POPBasicAnimation *anim1 = [POPBasicAnimation animationWithPropertyNamed:kPOPNavigationBarBarTintColor];
    anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    anim1.fromValue = navigationController.navigationBar.barTintColor;
    anim1.toValue = kBarTintColor;
    [navigationController.navigationBar pop_addAnimation:anim1 forKey:@"navBarBarTintColor"];
    
    POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPToolbarBarTintColor];
    anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    anim2.fromValue = navigationController.toolbar.barTintColor;
    anim2.toValue = kBarTintColor;
    [navigationController.toolbar pop_addAnimation:anim2 forKey:@"toolbarBarTintColor"];
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
	if (complete == TRUE) {
        return [UIColor colorWithRed:.5 green:1 blue:.5 alpha:0.5];
    } else if (complete == FALSE) {
        return [UIColor colorWithRed:1 green:.5 blue:0.5 alpha:0.5];
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
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"You successfully saved your context.");
        } else if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}

- (NSDateFormatter *)GMTDateFormatter
{
    if (_GmtDateFormatter == nil) {
        _GmtDateFormatter = [[NSDateFormatter alloc] init];
        [_GmtDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_GmtDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    }
    return _GmtDateFormatter;
}

@end
