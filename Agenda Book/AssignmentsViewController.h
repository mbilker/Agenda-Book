
#import <UIKit/UIKit.h>
#import "NewAssignmentViewController.h"
#import "EditAssignmentViewController.h"
#import "Info.h"

@class Info;

@interface AssignmentsViewController : UITableViewController <NewAssignmentViewControllerDelegate, EditAssignmentViewControllerDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate>

// @property (nonatomic, strong) NSMutableArray *assignments;
@property (nonatomic, strong) Info *info;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)loadRemote:(id)sender;

@end
