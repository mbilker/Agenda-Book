
#import <UIKit/UIKit.h>
#import "SubjectPickerViewController.h"

#import "Info.h"

@class EditClassViewController;

@protocol EditClassViewControllerDelegate <NSObject>
- (void)editClassViewControllerDidCancel:(EditClassViewController *)controller;
- (void)editClassViewController:(EditClassViewController *)controller didChange:(NSDictionary *)info;
@end

@interface EditClassViewController : UITableViewController <SubjectPickerViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id<EditClassViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UILabel *subjectDetail;
@property (nonatomic, strong) IBOutlet UILabel *classIDDetail;
@property (nonatomic, strong) IBOutlet UITextField *teacherField;

@property (nonatomic, strong) Info *classInfo;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
