#import "SubjectPickerViewController.h"

@class NewClassViewController;
@class Info;

@protocol NewClassViewControllerDelegate <NSObject>
- (void)newClassViewControllerDidCancel:(NewClassViewController *)controller;
- (void)newClassViewController:(NewClassViewController *)controller didAddInfo:(NSDictionary *)newClass;
@end

@interface NewClassViewController : UITableViewController <UITextFieldDelegate, SubjectPickerViewControllerDelegate>

@property (nonatomic, weak) id <NewClassViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *teacherTextField;
@property (nonatomic, strong) IBOutlet UITableViewCell *detailCell;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UITextField *classIdField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end