
#import <TapkuLibrary/TapkuLibrary.h>

@interface AssignmentsMonthViewController : TKCalendarMonthViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    TKProgressAlertView *_alertView;
    UITableView *_tableView;
    BOOL _loaded;
}

@property (nonatomic, strong) TKProgressAlertView *alertView;
@property (nonatomic, strong) UITableView *tableView;
//@property (nonatomic, strong) NSMutableDictionary *dataDictionary;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)goToToday:(id)sender;

@end
