
#import <UIKit/UIKit.h>
#import "NewAssignmentViewController.h"

@interface AssignmentsViewController : UITableViewController <NewAssignmentViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assignments;

- (IBAction)loadRemote:(id)sender;
- (IBAction)loadPlist:(id)sender;
- (IBAction)savePlist:(id)sender;
- (IBAction)reset:(id)sender;

@end
