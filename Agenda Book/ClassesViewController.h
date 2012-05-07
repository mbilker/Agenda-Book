
#import "NewClassViewController.h"
#import "EditClassViewController.h"
#import <iAd/iAd.h>

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate, EditClassViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate, ADBannerViewDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong) NSMutableArray *classes;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet ADBannerView *iAdBanner;

- (IBAction)editNavButtonPressed:(id)sender;
- (IBAction)tweet:(id)sender;

@end
