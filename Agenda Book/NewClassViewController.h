#import "SubjectPickerViewController.h"

@class NewClassViewController;
@class Info;

@protocol NewClassViewControllerDelegate <NSObject>
- (void)newClassViewControllerDidCancel:(NewClassViewController *)controller;
- (void)newClassViewController:(NewClassViewController *)controller didAddInfo:(Info *)player;
@end

@interface NewClassViewController : UITableViewController <SubjectPickerViewControllerDelegate>

@property (nonatomic, weak) id <NewClassViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *teacherTextField;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end