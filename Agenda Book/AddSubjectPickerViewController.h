
#import <UIKit/UIKit.h>

@class AddSubjectPickerViewController;

@protocol AddSubjectPickerViewControllerDelegate <NSObject>
- (void)addSubjectPickerViewControllerDidCancel:(AddSubjectPickerViewController *)controller;
- (void)addSubjectPickerViewController:(AddSubjectPickerViewController *)controller subject:(NSString *)newSubject;
@end

@interface AddSubjectPickerViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) id <AddSubjectPickerViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
