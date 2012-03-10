
#import "NewClassViewController.h"

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *classes;

- (IBAction)editNavButtonPressed:(id)sender;
- (IBAction)tweet:(id)sender;

@end
