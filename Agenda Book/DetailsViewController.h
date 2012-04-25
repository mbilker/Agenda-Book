
#import <UIKit/UIKit.h>

#import "Info.h"

@interface DetailsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *teacherName;
@property (nonatomic, strong) IBOutlet UILabel *subjectName;
@property (nonatomic, strong) IBOutlet UILabel *classID;
@property (nonatomic, strong) IBOutlet UILabel *assignmentsCount;
@property (nonatomic, strong) IBOutlet UILabel *doneAssignmentsCount;
@property (nonatomic, strong) IBOutlet UILabel *notDoneAssignmentsCount;

@property (nonatomic, strong) Info *classInfo;

@end
