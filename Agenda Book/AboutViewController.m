
#import "AboutViewController.h"
#import "Utils.h"

@implementation AboutViewController

@synthesize version;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init AboutViewController");
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *color = [UIColor greenColor];
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        self.navigationController.navigationBar.barTintColor = color;
    } else {
        self.navigationController.navigationBar.tintColor = color;
    }
    
    self.version.text = [NSString stringWithFormat:@"Version: %@\nBuild Date: %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBuildDate"]];
}

- (void)dealloc
{
	NSLog(@"dealloc AboutViewController");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[Utils instance] shouldAutorotate:interfaceOrientation];
}

@end
