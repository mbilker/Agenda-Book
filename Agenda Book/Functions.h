
#import <Foundation/Foundation.h>

@interface Functions : NSObject

+ (Functions *) sharedFunctions;

- (BOOL)shouldAutorotate:(UIInterfaceOrientation)interfaceOrientation;
- (NSString *)assignmentPath;
- (NSString *)classPath;
- (NSString *)subjectPath;
- (NSURL *)assignmentiCloud;
- (NSURL *)classiCloud;
- (NSURL *)subjectiCloud;
- (UIColor *)colorForComplete:(BOOL)complete;
- (UIColor *)determineClassComplete:(NSString *)string;

@end
