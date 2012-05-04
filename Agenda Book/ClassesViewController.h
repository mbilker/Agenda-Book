
#import "NewClassViewController.h"
#import "EditClassViewController.h"

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate, EditClassViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong) NSMutableArray *classes;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)editNavButtonPressed:(id)sender;
- (IBAction)tweet:(id)sender;

@end
