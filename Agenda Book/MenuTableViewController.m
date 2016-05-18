
#import "MenuTableViewController.h"

#import "MenuCell.h"
#import "MenuTableViewHeader.h"

NSString * const MenuRowReuseIdentifier = @"MenuRow";
NSString * const MenuHeaderReuseIdentifier = @"MenuTableViewHeader";

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        NSLog(@"init %@", [self class]);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc %@", [self class]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[MenuCell class] forCellReuseIdentifier:MenuRowReuseIdentifier];
    [self.tableView registerClass:[MenuTableViewHeader class] forHeaderFooterViewReuseIdentifier:MenuHeaderReuseIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.25];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:MenuHeaderReuseIdentifier];
    headerView.textLabel.text = @"Testing";
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FLT_EPSILON;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MenuRowReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"Testing";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
