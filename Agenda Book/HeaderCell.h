
#import <UIKit/UIKit.h>

@interface HeaderCell : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *label;

+ (HeaderCell *)attachToTableView:(UITableView *)tableView;
+ (HeaderCell *)attachToScrollView:(UIScrollView *)scrollView;

@end
