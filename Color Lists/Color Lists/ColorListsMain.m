
#import "ColorListsMain.h"

@implementation ColorListsMain

- (id) initWithPickerMask:(NSUInteger)mask colorPanel:(NSColorPanel *)owningColorPanel {
	return [super initWithPickerMask:mask colorPanel:owningColorPanel];
}

- (NSView *) provideNewView:(BOOL) initialRequest {
	if(initialRequest) {
		self.colorLists = [[ColorLists alloc] init];
		self.colorLists.main = self;
		NSBundle * currentBundle = [NSBundle bundleForClass:[self class]];
		[currentBundle loadNibNamed:@"ColorLists" owner:self.colorLists topLevelObjects:nil];
	}
	
	return self.colorLists.view;
}

- (void) setColor:(NSColor *) newColor {
	[[self colorPanel] setColor:newColor];
}

- (BOOL) supportsMode:(NSColorPanelMode) mode {
	return TRUE;
}

- (NSColorPanelMode) currentMode {
	return 1024;
}

- (NSString *) buttonToolTip {
	return @"Color Lists";
}

@end
