
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Assignment : NSManagedObject

@property (nonatomic, strong) NSString *assignmentText;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, strong) NSDate *dueDate;
@property (nonatomic, strong) NSString *teacher;

@end
