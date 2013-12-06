#import <UIKit/UIKit.h>

@interface NSString (TruncateToWidth)

- (NSString *)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font;

@end