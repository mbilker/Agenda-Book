
#import <Foundation/Foundation.h>
#import "Assignment.h"
#import "AppDelegate.h"

//#define classServer @"localhost:8080"
#define classServer @"classes.mbilker.us"

@interface Functions : NSObject

+ (Functions *) sharedFunctions;

- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation;
- (NSDate *)dateWithOutTime:(NSDate *)datDate;
/* 
- (NSString *)assignmentPath;
- (NSString *)classPath;
- (NSString *)subjectPath;
- (NSURL *)assignmentiCloud;
- (NSURL *)classiCloud;
- (NSURL *)subjectiCloud;
*/
- (UIColor *)colorForComplete:(BOOL)complete;
- (UIColor *)determineClassComplete:(NSString *)string context:(NSManagedObjectContext *)context;
- (void)saveContext:(NSManagedObjectContext *)context;

@end
