
#import "ClassIDViewController.h"

@implementation ClassIDViewController

@synthesize delegate;
@synthesize enteredClassID;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		NSLog(@"init ClassIDViewController");
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"dealloc ClassIDViewController");
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.enteredClassID.delegate = self;
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.enteredClassID becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.text.length > 2) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return !([newString length] > 2);
    }
    return [string isEqualToString:@""] || ([string stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].length > 0);
}

- (IBAction)done:(id)sender
{
    int i = [self.enteredClassID.text intValue];
    if (i == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Class ID" message:@"You did not enter a Class ID" delegate:self cancelButtonTitle:@"Use None" otherButtonTitles:@"Reenter", nil];
        alert.delegate = self;
        [alert show];
        return;
    }
    [self.delegate classIDViewController:self didAddClassID:[NSString stringWithFormat:@"%d",[self.enteredClassID.text intValue]]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"cancel: '%d'",[alertView cancelButtonIndex]);
    //NSLog(@"button: '%d'",buttonIndex);
    if (buttonIndex == [alertView cancelButtonIndex]) {
        //NSLog(@"using none");
        [self.delegate classIDViewController:self didAddClassID:[NSString stringWithFormat:@"%d",[self.enteredClassID.text intValue]]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
