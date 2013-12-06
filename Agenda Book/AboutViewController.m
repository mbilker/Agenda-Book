
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
    self.version.text = [NSString stringWithFormat:@"Version: b%d",[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue]];
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
