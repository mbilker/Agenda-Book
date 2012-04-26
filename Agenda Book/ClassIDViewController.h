
#import <UIKit/UIKit.h>

@class ClassIDViewController;

@protocol ClassIDViewControllerDelegate <NSObject>
- (void)classIDViewControllerDidCancel:(ClassIDViewController *)controller;
- (void)classIDViewController:(ClassIDViewController *)controller didAddClassID:(NSString *)classID;
@end

@interface ClassIDViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id <ClassIDViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITextField *enteredClassID;

- (IBAction)done:(id)sender;

@end
