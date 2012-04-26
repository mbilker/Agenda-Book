
#import <UIKit/UIKit.h>

#import "Assignment.h"

@class EditAssignmentViewController;

@protocol EditAssignmentViewControllerDelegate <NSObject>
- (void)editAssignmentViewControllerDidCancel:(EditAssignmentViewController *)controller;
- (void)editAssignmentViewController:(EditAssignmentViewController *)controller didChange:(Assignment *)assignment;
@end

@interface EditAssignmentViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<EditAssignmentViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *assignmentField;
@property (nonatomic, strong) IBOutlet UITableViewCell *dueCell;
@property (nonatomic, strong) IBOutlet UIDatePicker *duePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) Assignment *assignment;

- (IBAction)dateChanged:(id)sender;

@end
