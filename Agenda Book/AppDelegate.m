
#import <QuartzCore/QuartzCore.h>

#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>

#import "AppDelegate.h"
#import "ClassesViewController.h"
#import "MenuTableViewController.h"
#import "Utils.h"

#import "Info.h"
#import "Assignment.h"

#import "Constants.h"

@interface AppDelegate () <MSDynamicsDrawerViewControllerDelegate>

@property (nonatomic, strong) UIImageView *windowBackground;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
    [MagicalRecord setupCoreDataStackWithiCloudContainer:kUbiquityContainerIdentifier contentNameKey:@"Agenda Book" localStoreNamed:@"Data" cloudStorePathComponent:@"data" completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAllViews object:nil];
    }];
    
    self.dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.window.rootViewController;
    self.dynamicsDrawerViewController.delegate = self;
    
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerScaleStyler styler], [MSDynamicsDrawerFadeStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
    
    MenuTableViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    
    [self.dynamicsDrawerViewController addStyler:[MSDynamicsDrawerShadowStyler styler] forDirection:MSDynamicsDrawerDirectionLeft];
    [self.dynamicsDrawerViewController setRevealWidth:200.0f forDirection:MSDynamicsDrawerDirectionLeft];
    
    self.classesViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"Main"];
    [self.dynamicsDrawerViewController setPaneViewController:self.classesViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.dynamicsDrawerViewController;
    
    [self.window makeKeyAndVisible];
    
    [self.window addSubview:self.windowBackground];
    [self.window sendSubviewToBack:self.windowBackground];
    [self.windowBackground sizeToFit];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

#pragma mark - AppDelegate

- (UIImage *)resizeImageToSize:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    
    return newImage;
}

- (UIImageView *)windowBackground
{
    if (!_windowBackground) {
        UIImage *originalImage = [UIImage imageNamed:@"Window Background"];
        UIImage *scaledImage = [self resizeImageToSize:originalImage targetSize:[UIScreen mainScreen].bounds.size];
        
        _windowBackground = [[UIImageView alloc] initWithImage:scaledImage];
    }
    return _windowBackground;
}

- (NSString *)descriptionForPaneState:(MSDynamicsDrawerPaneState)paneState
{
    switch (paneState) {
        case MSDynamicsDrawerPaneStateOpen:
            return @"MSDynamicsDrawerPaneStateOpen";
        case MSDynamicsDrawerPaneStateClosed:
            return @"MSDynamicsDrawerPaneStateClosed";
        case MSDynamicsDrawerPaneStateOpenWide:
            return @"MSDynamicsDrawerPaneStateOpenWide";
        default:
            return nil;
    }
}

- (NSString *)descriptionForDirection:(MSDynamicsDrawerDirection)direction
{
    switch (direction) {
        case MSDynamicsDrawerDirectionTop:
            return @"MSDynamicsDrawerDirectionTop";
        case MSDynamicsDrawerDirectionLeft:
            return @"MSDynamicsDrawerDirectionLeft";
        case MSDynamicsDrawerDirectionBottom:
            return @"MSDynamicsDrawerDirectionBottom";
        case MSDynamicsDrawerDirectionRight:
            return @"MSDynamicsDrawerDirectionRight";
        default:
            return nil;
    }
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    NSLog(@"Drawer view controller may update to state `%@` for direction `%@`", [self descriptionForPaneState:paneState], [self descriptionForDirection:direction]);
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
    NSLog(@"Drawer view controller did update to state `%@` for direction `%@`", [self descriptionForPaneState:paneState], [self descriptionForDirection:direction]);
}

@end