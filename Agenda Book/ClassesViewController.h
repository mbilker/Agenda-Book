
#import "NewClassViewController.h"

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate>

@property (atomic, retain) NSMutableArray *classes;

- (IBAction)tweet:(id)sender;

@end
