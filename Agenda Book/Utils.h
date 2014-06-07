
#import <UIKit/UIKit.h>

//#define classServer @"localhost:8080"
#define classServer @"classes.mbilker.us"

@class Info;

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
