#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Info;

@interface Assignment : NSManagedObject

@property (nonatomic, strong) NSString *assignmentText;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, strong) NSDate *dueDate;

@property (nonatomic, strong) Info *teacher;

- (instancetype)initUsingDefaultContext;

@end
