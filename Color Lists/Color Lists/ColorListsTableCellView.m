
#import "ColorListsTableCellView.h"

@implementation ColorListsTableCellView

- (void) setBackgroundStyle:(NSBackgroundStyle) backgroundStyle {
	NSColor * textColor = (backgroundStyle == NSBackgroundStyleDark) ? [NSColor selectedControlTextColor] : [NSColor controlTextColor];
	self.label.textColor = textColor;
	[super setBackgroundStyle:backgroundStyle];
}

@end
