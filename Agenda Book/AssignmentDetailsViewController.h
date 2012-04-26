
#import <UIKit/UIKit.h>

#import "Assignment.h"

@interface AssignmentDetailsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *assignmentText;
@property (nonatomic, strong) IBOutlet UILabel *complete;
@property (nonatomic, strong) IBOutlet UILabel *dueDate;

@property (nonatomic, strong) Assignment *assignment;

@end
