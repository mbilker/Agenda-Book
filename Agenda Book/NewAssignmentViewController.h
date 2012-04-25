
#import <UIKit/UIKit.h>

@class NewAssignmentViewController;
@class Assignment;

@protocol NewAssignmentViewControllerDelegate <NSObject>
- (void)addAssignmentViewControllerDidCancel:(NewAssignmentViewController *)controller;
- (void)addAssignmentViewController:(NewAssignmentViewController *)controller didAddAssignment:(Assignment *)newAssignment;
@end

@interface NewAssignmentViewController : UITableViewController <UITextFieldDelegate> {
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, weak) id <NewAssignmentViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *assignmentField;
@property (nonatomic, strong) IBOutlet UITableViewCell *dateCell;
@property (nonatomic, strong) IBOutlet UIDatePicker *duePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (IBAction)cancel:(id)sender;
- (IBAction)dateChanged:(id)sender;
- (IBAction)done:(id)sender;

@end
