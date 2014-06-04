#import "NSString-truncateToWidth.h"

#define ellipsis @"…"

@implementation NSString (TruncateToWidth)

- (NSString *)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font
{
    // Create copy that will be the returned result
    NSMutableString *truncatedString = [self mutableCopy];
    
    // Make sure string is longer than requested width
    //if ([self sizeWithFont:font].width > width)
    if ([self sizeWithAttributes:@{ NSFontAttributeName: font }].width > width)
    {
        // Accommodate for ellipsis we'll tack on the end
        //width -= [ellipsis sizeWithFont:font].width;
        width -= [ellipsis sizeWithAttributes:@{ NSFontAttributeName: font }].width;
        
        // Get range for last character in string
        NSRange range = {truncatedString.length - 1, 1};
        
        // Loop, deleting characters until string fits within width
        //while ([truncatedString sizeWithFont:font].width > width)
        while ([truncatedString sizeWithAttributes:@{ NSFontAttributeName: font }].width > width)
        {
            // Delete character at end
            [truncatedString deleteCharactersInRange:range];
            
            // Move back another character
            range.location--;
        }
        
        // Append ellipsis
        [truncatedString replaceCharactersInRange:range withString:ellipsis];
    }
    
    return truncatedString;
}

@end