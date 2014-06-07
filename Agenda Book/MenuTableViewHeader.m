
#import "MenuTableViewHeader.h"

@implementation MenuTableViewHeader

#pragma mark - NSObject

+ (void)load
{
    id labelAppearance = [UILabel appearanceWhenContainedIn:[self class], nil];
    [labelAppearance setFont:[UIFont systemFontOfSize:13.0]];
    [labelAppearance setTextColor:[UIColor whiteColor]];
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgoundView = [UIView new];
        backgoundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.backgroundView = backgoundView;
    }
    return self;
}

@end
