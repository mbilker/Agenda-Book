
#import <UIKit/UIKit.h>
#import "NewAssignmentViewController.h"
#import "Info.h"

@class Info;

@interface AssignmentsViewController : UITableViewController <NewAssignmentViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assignments;
@property (nonatomic, strong) Info *info;

- (IBAction)loadRemote:(id)sender;
- (IBAction)savePlist:(id)sender;

@end
