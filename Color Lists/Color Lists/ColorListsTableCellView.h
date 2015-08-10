
#import <Cocoa/Cocoa.h>

extern NSString * const ColorListsTableCellViewChange;

@interface ColorListsTableCellView : NSTableCellView <NSTextFieldDelegate>

@property NSString * filePath;
@property NSColorList * colorList;
@property IBOutlet NSTextField * label;
@property IBOutlet NSView * colorView;

@end
