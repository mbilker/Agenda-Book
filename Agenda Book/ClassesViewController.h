
#import "SubjectViewController.h"

@interface ClassesViewController : UITableViewController <SubjectViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *players;

- (IBAction)tweet:(id)sender;

@end
