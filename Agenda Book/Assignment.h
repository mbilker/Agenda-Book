
#import <Foundation/Foundation.h>

@interface Assignment : NSObject

@property (nonatomic, copy) NSString *assignmentText;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, copy) NSDate *dueDate;

@end
