
#import <Cocoa/Cocoa.h>

@class ColorListsMain;

@interface ColorLists : NSViewController <NSTableViewDataSource,NSTableViewDelegate>

@property ColorListsMain * main;
@property IBOutlet NSMenu * optionsMenu;
@property IBOutlet NSTableView * tableView;
@property IBOutlet NSPopUpButton * colorListsPopup;
@property IBOutlet NSButton * optionsButton;
@property IBOutlet NSWindow * renameWindow;
@property IBOutlet NSTextField * renameField;

- (void) refresh;

@end
