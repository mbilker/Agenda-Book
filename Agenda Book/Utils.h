
#import <UIKit/UIKit.h>

#import "Info.h"
#import "Assignment.h"
#import "AppDelegate.h"

//#define classServer @"localhost:8080"
#define classServer @"classes.mbilker.us"

@interface Utils : NSObject

+ (Utils *) instance;

- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation;
- (void)initializeNavigationController:(UINavigationController *)navigationController;
- (NSDate *)dateWithOutTime:(NSDate *)datDate;- (UIColor *)colorForComplete:(BOOL)complete;
- (BOOL)determineClassComplete:(Info *)string;
- (UIColor *)determineClassCompleteColor:(Info *)string;

- (void)saveContext;

- (NSDateFormatter *)GMTDateFormatter;

@end
