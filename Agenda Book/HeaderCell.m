
#import "HeaderCell.h"

#define DEFAULT_FOREGROUND_COLOR [UIColor whiteColor]
#define DEFAULT_BACKGROUND_COLOR [UIColor colorWithWhite:0.10f alpha:1.0f]

@implementation HeaderCell
{
    CGFloat _originalTopContentInset;
    
    UIView *_contentView;
    UILabel *_label;
}

+ (HeaderCell *)attachToTableView:(UITableView*)tableView
{
    return [self attachToScrollView:tableView];
}

+ (HeaderCell *)attachToScrollView:(UIScrollView *)scrollView
{
    HeaderCell *existingHeaderCell = [self findHeaderCellInScrollView:scrollView];
    if (existingHeaderCell != nil) {
        return existingHeaderCell;
    }
    
    HeaderCell *headerCell = [[HeaderCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, scrollView.frame.size.width, 0.0f) andScrollView:scrollView];
    
    [scrollView addSubview:headerCell];
    
    return headerCell;
}

+ (HeaderCell *)findHeaderCellInScrollView:(UIScrollView *)scrollView
{
    for (UIView* subview in scrollView.subviews) {
        if ([subview isKindOfClass:[self class]]) {
            return (HeaderCell *)subview;
        }
    }
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame andScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        self.scrollView = scrollView;
        
        _originalTopContentInset = self.scrollView.contentInset.top;
        
        [self setupContentView];
        
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    }
    return self;
}

- (void)setupContentView
{
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 50.0f)];
    _contentView.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f];
    [self addSubview:_contentView];
    
    _label = [[UILabel alloc] init];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.numberOfLines = 0;
    _label.opaque = TRUE;
    _label.frame = _contentView.frame;
    [_contentView addSubview:_label];
}

- (void)dealloc
{
    NSLog(@"dealloc HeaderCell");
}

- (void)setHeightAndOffsetOfCell:(CGFloat)offset
{
    CGRect newFrame = self.frame;
    newFrame.size.height = offset;
    newFrame.origin.y = -offset;
    self.frame = newFrame;
}

@end
