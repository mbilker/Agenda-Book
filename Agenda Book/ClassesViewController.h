
#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

#import "NewClassViewController.h"
#import "EditClassViewController.h"

@interface ClassesViewController : UITableViewController <NewClassViewControllerDelegate, EditClassViewControllerDelegate, UIAlertViewDelegate, NSFetchedResultsControllerDelegate, ADBannerViewDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet ADBannerView *iAdBanner;

- (IBAction)tweet:(id)sender;
- (IBAction)menuButtonPressed:(id)sender;

@end
