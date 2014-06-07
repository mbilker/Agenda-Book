
#import <UIKit/UIKit.h>

@class Info;

@interface AssignmentsViewController : UITableViewController

@property (nonatomic, strong) Info *info;

- (IBAction)loadRemote:(id)sender;

@end
