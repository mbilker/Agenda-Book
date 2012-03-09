
#import "NewClassViewController.h"

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *classes;

- (IBAction)tweet:(id)sender;

@end
