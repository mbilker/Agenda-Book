
#import <TapkuLibrary/TapkuLibrary.h>

@interface AssignmentsMonthViewController : TKCalendarMonthViewController <UITableViewDataSource, UITableViewDelegate> {
    TKProgressAlertView *_alertView;
    UITableView *_tableView;
    BOOL _loaded;
}

@property (nonatomic, strong) TKProgressAlertView *alertView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) NSMutableArray *dateArray;
//@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)goToToday:(id)sender;

@end
