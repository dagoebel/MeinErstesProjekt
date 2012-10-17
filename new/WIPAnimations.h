
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (Animation)

- (void) moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option;
- (void) moveToAndSize:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions) option size:(double) size rotate:(double) rotate;
- (void) downUnder:(float)secs option:(UIViewAnimationOptions)option;
- (void) addSubviewWithZoomInAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option;
- (void) removeWithZoomOutAnimation:(float)secs option:(UIViewAnimationOptions)option;
- (void) addSubviewWithFadeAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option;
- (void) removeWithSinkAnimation:(int)steps;
- (void) removeWithSinkAnimationRotateTimer:(NSTimer*) timer;

@end
