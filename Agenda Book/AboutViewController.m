
#import "AboutViewController.h"
#import "Utils.h"

@implementation AboutViewController

@synthesize version;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init AboutViewController");
	}
	return self;
}

- (void)viewDidLoad
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        UIView *oldView = self.view;
        
        self.view = [[UIView alloc] initWithFrame:oldView.frame];
        self.view.backgroundColor = [UIColor whiteColor];
        oldView.autoresizingMask = nil;
        
        CGRect oldViewFrame = oldView.frame;
        oldViewFrame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
        oldViewFrame.size.height = self.view.frame.size.height - self.navigationController.toolbar.frame.size.height;
        oldView.frame = oldViewFrame;
        
        [self.view addSubview:oldView];
    }
    
    [super viewDidLoad];
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
