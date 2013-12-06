
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Info : NSManagedObject

@property (nonatomic, strong) NSString *teacher;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *classid;

@property (nonatomic, strong) NSSet *assignments;

@end
