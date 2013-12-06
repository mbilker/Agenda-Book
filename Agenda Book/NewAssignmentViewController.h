
#import <UIKit/UIKit.h>

@class NewAssignmentViewController;
@class Assignment;
@class Info;

@protocol NewAssignmentViewControllerDelegate <NSObject>
- (void)addAssignmentViewControllerDidCancel:(NewAssignmentViewController *)controller;
- (void)addAssignmentViewControllerAdded:(NewAssignmentViewController *)controller;
@end

@interface NewAssignmentViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <NewAssignmentViewControllerDelegate> delegate;
@property (nonatomic, weak) Info *info;

@property (nonatomic, strong) IBOutlet UIView *hiddenView;
@property (nonatomic, strong) IBOutlet UITextField *assignmentField;
@property (nonatomic, strong) IBOutlet UITableViewCell *dateCell;
@property (nonatomic, strong) IBOutlet UIDatePicker *duePicker;

- (IBAction)cancel:(id)sender;
- (IBAction)dateChanged:(id)sender;
- (IBAction)done:(id)sender;

@end
