#import "SubjectPickerViewController.h"
#import "ClassIDViewController.h"

@class NewClassViewController;
@class Info;

@protocol NewClassViewControllerDelegate <NSObject>
- (void)newClassViewControllerDidCancel:(NewClassViewController *)controller;
- (void)newClassViewController:(NewClassViewController *)controller didAddInfo:(NSDictionary *)newClass;
@end

@interface NewClassViewController : UITableViewController <SubjectPickerViewControllerDelegate, ClassIDViewControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id <NewClassViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *teacherTextField;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UILabel *classIDLabel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end