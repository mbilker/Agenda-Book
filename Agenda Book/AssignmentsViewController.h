
#import <UIKit/UIKit.h>
#import "NewAssignmentViewController.h"
#import "EditAssignmentViewController.h"
#import "Info.h"

@class Info;

@interface AssignmentsViewController : UITableViewController <NewAssignmentViewControllerDelegate, UIActionSheetDelegate, EditAssignmentViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assignments;
@property (nonatomic, strong) Info *info;

- (IBAction)loadRemote:(id)sender;

@end
