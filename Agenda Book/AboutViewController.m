
#import <POP/POP.h>

#import "AboutViewController.h"
#import "Utils.h"

@implementation AboutViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIColor *color = [UIColor colorWithRed:0.81f green:0.89f blue:0.95f alpha:1.0f];
    
    POPBasicAnimation *anim1 = [POPBasicAnimation animationWithPropertyNamed:kPOPNavigationBarBarTintColor];
    anim1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    anim1.fromValue = self.navigationController.navigationBar.barTintColor;
    anim1.toValue = color;
    [self.navigationController.navigationBar pop_addAnimation:anim1 forKey:@"navBarTintChange"];
    
    POPBasicAnimation *anim2 = [POPBasicAnimation animationWithPropertyNamed:kPOPToolbarBarTintColor];
    anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    anim2.fromValue = self.navigationController.toolbar.barTintColor;
    anim2.toValue = color;
    [self.navigationController.toolbar pop_addAnimation:anim2 forKey:@"toolbarTintChange"];
    
    self.version.text = [NSString stringWithFormat:@"Version: %@\nBuild Date: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBuildDate"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

@end
