
#import <Cocoa/Cocoa.h>
#import "ColorLists.h"

@interface ColorListsMain : NSColorPicker <NSColorPickingCustom>

@property ColorLists * colorLists;

- (void) setColor:(NSColor *) newColor;

@end
