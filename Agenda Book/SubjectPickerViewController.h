
#import <UIKit/UIKit.h>
#import "AddSubjectPickerViewController.h"
#import "Subject.h"

@class SubjectPickerViewController;

@protocol SubjectPickerViewControllerDelegate <NSObject>
- (void)subjectPickerViewController:(SubjectPickerViewController *)controller didSelectSubject:(NSString *)game;
@end

@interface SubjectPickerViewController : UITableViewController <AddSubjectPickerViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id <SubjectPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *subject;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end