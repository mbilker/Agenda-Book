
#import <UIKit/UIKit.h>

@class NewAssignmentViewController;
@class Assignment;

@protocol NewAssignmentViewControllerDelegate <NSObject>
- (void)addAssignmentViewControllerDidCancel:(NewAssignmentViewController *)controller;
- (void)addAssignmentViewController:(NewAssignmentViewController *)controller didAddAssignment:(Assignment *)newAssignment;
@end

@interface NewAssignmentViewController : UITableViewController

@property (nonatomic, weak) id <NewAssignmentViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *assignmentField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
