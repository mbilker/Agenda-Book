
#import "NewClassViewController.h"
#import "EditClassViewController.h"

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, EditClassViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *classes;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;

- (IBAction)editNavButtonPressed:(id)sender;
- (IBAction)tweet:(id)sender;

@end
