
#import <UIKit/UIKit.h>
#import "AddSubjectPickerViewController.h"

@class SubjectPickerViewController;

@protocol SubjectPickerViewControllerDelegate <NSObject>
- (void)subjectPickerViewController:(SubjectPickerViewController *)controller didSelectSubject:(NSString *)game;
@end

@interface SubjectPickerViewController : UITableViewController <AddSubjectPickerViewControllerDelegate>

@property (nonatomic, weak) id <SubjectPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *subject;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end