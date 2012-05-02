
#import <TapkuLibrary/TapkuLibrary.h>

@interface AssignmentsMonthViewController : TKCalendarMonthViewController <UITableViewDataSource, UITableViewDelegate> {
    TKProgressAlertView *_alertView;
    UITableView *_tableView;
}

@property (nonatomic, strong) TKProgressAlertView *alertView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *dataDictionary;
@property (nonatomic, strong) NSMutableArray *dateArray;

- (IBAction)goToToday:(id)sender;

@end
