
#import "ColorListsTableCellView.h"

NSString * const ColorListsTableCellViewChange = @"ColorListsTableCellViewChange";

@interface ColorListsTableCellView ()
@property NSString * previousText;
@end

@implementation ColorListsTableCellView

- (void) awakeFromNib {
	self.label.delegate = self;
}

- (BOOL) control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
	self.previousText = self.label.stringValue;
	return TRUE;
}

- (BOOL) control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
	NSString * newKey = self.label.stringValue;
	if(!self.previousText) {
		return TRUE;
	}
	
	if([self.previousText isEqualToString:newKey]) {
		return TRUE;
	}
	
	if([self.colorList colorWithKey:newKey]) {
		NSBeep();
		self.label.stringValue = self.previousText;
		return TRUE;
	}
	
	NSColor * color = [self.colorList colorWithKey:self.previousText];
	[self.colorList removeColorWithKey:self.previousText];
	[self.colorList setColor:color forKey:newKey];
	[self.colorList writeToFile:self.filePath];
	
	self.previousText = nil;
	
	[NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(postNotification) userInfo:nil repeats:FALSE];
	
	return TRUE;
}

- (void) postNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:ColorListsTableCellViewChange object:nil];
}

- (void) setBackgroundStyle:(NSBackgroundStyle) backgroundStyle {
	NSColor * textColor = (backgroundStyle == NSBackgroundStyleDark) ? [NSColor selectedControlTextColor] : [NSColor controlTextColor];
	self.label.textColor = textColor;
	[super setBackgroundStyle:backgroundStyle];
}

@end
