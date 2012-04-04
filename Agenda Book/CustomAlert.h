#import <Foundation/Foundation.h>
@interface CustomAlert : UIAlertView {
	int canIndex;
	BOOL disableDismiss;
    BOOL canVirate;
}

-(void) setBackgroundColor:(UIColor *) background withStrokeColor:(UIColor *) stroke;

- (void)disableDismissForIndex:(int)index_;
- (void)dismissAlert;
- (void)vibrateAlert:(float)seconds;

- (void)moveRight;
- (void)moveLeft;

- (void)hideAfter:(float)seconds;

- (void)stopVibration;

@end
