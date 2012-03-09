#import "SubjectPickerViewController.h"

@class SubjectViewController;
@class Player;

@protocol SubjectViewControllerDelegate <NSObject>
- (void)subjectViewControllerDidCancel:(SubjectViewController *)controller;
- (void)subjectViewController:(SubjectViewController *)controller didAddPlayer:(Player *)player;
@end

@interface SubjectViewController : UITableViewController <SubjectPickerViewControllerDelegate>

@property (nonatomic, weak) id <SubjectViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *teacherTextField;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end