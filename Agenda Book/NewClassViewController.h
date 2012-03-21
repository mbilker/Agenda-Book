#import "SubjectPickerViewController.h"
#import "ClassIDViewController.h"

@class NewClassViewController;
@class Info;

@protocol NewClassViewControllerDelegate <NSObject>
- (void)newClassViewControllerDidCancel:(NewClassViewController *)controller;
- (void)newClassViewController:(NewClassViewController *)controller didAddInfo:(Info *)newClass;
@end

@interface NewClassViewController : UITableViewController <SubjectPickerViewControllerDelegate, ClassIDViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id <NewClassViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *teacherTextField;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UILabel *classIDLabel;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end