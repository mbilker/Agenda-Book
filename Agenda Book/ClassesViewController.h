
#import "NewClassViewController.h"

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *classes;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;

- (IBAction)editNavButtonPressed:(id)sender;
- (IBAction)tweet:(id)sender;

@end
