
#import <TapkuLibrary/TapkuLibrary.h>

@interface AssignmentsMonthViewController : TKCalendarMonthViewController <UITableViewDataSource, UITableViewDelegate> {
    TKProgressAlertView *_alertView;
    UITableView *_tableView;
    BOOL _loaded;
}

@property (nonatomic, strong) TKProgressAlertView *alertView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *dataDictionary;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (IBAction)goToToday:(id)sender;

@end
