
#import "ColorLists.h"
#import "CLMenuItem.h"
#import "ColorListsTableCellView.h"
#import "ColorListsMain.h"

@interface ColorLists ()
@end

@implementation ColorLists

- (void) awakeFromNib {
	[self setupTableView];
	[self reloadColorLists];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCellChange:) name:ColorListsTableCellViewChange object:nil];
}

- (void) setupTableView {
	NSBundle * currentBundle = [NSBundle bundleForClass:[self class]];
	NSNib * nib = [[NSNib alloc] initWithNibNamed:@"ColorListsTableCellView" bundle:currentBundle];
	[self.tableView registerNib:nib forIdentifier:@"ColorListsTableCellView"];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView registerForDraggedTypes:@[NSColorPboardType]];
}

- (void) reloadColorLists {
	[self.colorListsPopup.menu removeAllItems];
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSString * userLibrary = [@"~/Library/Colors/" stringByExpandingTildeInPath];
	NSArray * colorLists = [fileManager contentsOfDirectoryAtPath:userLibrary error:nil];
	
	for(NSString * f in colorLists) {
		if([f containsString:@".clr"]) {
			NSString * name = [f stringByDeletingPathExtension];
			NSString * path = [[NSString stringWithFormat:@"~/Library/Colors/%@",f] stringByExpandingTildeInPath];
			NSColorList * colorList = [[NSColorList alloc] initWithName:name fromFile:path];
			
			CLMenuItem * menuItem = [[CLMenuItem alloc] initWithTitle:name action:@selector(onCLItem:) keyEquivalent:@""];
			menuItem.filePath = path;
			menuItem.target = self;
			menuItem.colorList = colorList;
			
			[self.colorListsPopup.menu addItem:menuItem];
		}
	}
	
	[self.tableView reloadData];
}

- (void) refresh {
	NSString * selectedItemTitle = self.colorListsPopup.selectedItem.title;
	[self reloadColorLists];
	
	if([self.colorListsPopup itemWithTitle:selectedItemTitle]) {
		[self.colorListsPopup selectItemWithTitle:selectedItemTitle];
	} else {
		[self.colorListsPopup selectItemAtIndex:0];
	}
	
	[self.tableView reloadData];
}

- (NSArray *) sortedKeysForColorList:(NSColorList *) colorList {
	NSArray * keys = [colorList allKeys];
	NSArray * sorted = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString * a = (NSString *) obj1;
		NSString * b = (NSString *) obj2;
		return [a compare:b options:NSCaseInsensitiveSearch|NSNumericSearch];
	}];
	return sorted;
}

- (void) onCellChange:(id) sender {
	NSInteger row = self.tableView.selectedRow;
	ColorListsTableCellView * cell = (ColorListsTableCellView *)[self.tableView viewAtColumn:0 row:row makeIfNecessary:FALSE];
	
	NSString * selectedKey = cell.label.stringValue;
	[self.tableView reloadData];
	
	CLMenuItem * item = (CLMenuItem *)self.colorListsPopup.selectedItem;
	NSArray * keys = [self sortedKeysForColorList:item.colorList];
	NSInteger newRow = 0;
	BOOL found = FALSE;
	
	for(NSString * key in keys) {
		if([key isEqualToString:selectedKey]) {
			found = TRUE;
			break;
		}
		newRow++;
	}
	
	if(found) {
		[[self tableView] selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:FALSE];
	}
}

- (void) onCLItem:(CLMenuItem *) item {
	[self.tableView reloadData];
}

- (IBAction) reload:(id) sender {
	[self refresh];
}

- (IBAction) showOptions:(id) sender {
	[self.optionsMenu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, 0) inView:self.optionsButton];
}

- (IBAction) newColorList:(id) sender {
	NSColorList * colorList = [[NSColorList alloc] init];
	[colorList setColor:[NSColor colorWithRed:1.0 green:0.0004 blue:0.3624 alpha:1.0] forKey:@"Pink"];
	NSString * path = [@"~/Library/Colors/New Color Palette.clr" stringByExpandingTildeInPath];
	__unused BOOL result = [colorList writeToFile:path];
	[self reloadColorLists];
	[self.colorListsPopup selectItemWithTitle:@"New Color Palette"];
	[self.tableView reloadData];
	[self renameColorList:sender];
}

- (IBAction) renameColorList:(id) sender {
	self.renameField.stringValue = self.colorListsPopup.selectedItem.title;
	[self.view.window beginSheet:self.renameWindow completionHandler:nil];
}

- (IBAction) cancelRename:(id)sender {
	[self.view.window endSheet:self.renameWindow];
}

- (IBAction) commitRenameColorList:(id)sender {
	NSString * newName = self.renameField.stringValue;
	
	if(newName.length < 1) {
		NSBeep();
		return;
	}
	
	if([newName isEqualToString:@"New Color Palette"]) {
		NSBeep();
		return;
	}
	
	NSFileManager * fileManager = [NSFileManager defaultManager];
	CLMenuItem * item = (CLMenuItem *)self.colorListsPopup.selectedItem;
	NSColorList * list = item.colorList;
	NSString * newPath = [[NSString stringWithFormat:@"~/Library/Colors/%@.clr",newName] stringByExpandingTildeInPath];
	
	if([fileManager fileExistsAtPath:newPath isDirectory:nil]) {
		NSBeep();
		NSBundle * currentBundle = [NSBundle bundleForClass:[self class]];
		NSAlert * alert = [[NSAlert alloc] init];
		alert.messageText = @"Duplicate Name";
		alert.informativeText = @"A color palette with that name already exists.";
		NSString * iconPath = [currentBundle pathForResource:@"ColorListsLargeIcon" ofType:@"tiff"];
		alert.icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
		[alert addButtonWithTitle:@"OK"];
		[alert runModal];
		return;
	}
	
	[list writeToFile:newPath];
	[[NSFileManager defaultManager] removeItemAtPath:item.filePath error:nil];
	item.filePath = newPath;
	
	[self refresh];
	
	if([self.colorListsPopup itemWithTitle:newName]) {
		[self.colorListsPopup selectItemWithTitle:newName];
	} else {
		[self.colorListsPopup selectItemAtIndex:0];
	}
	
	[self.tableView reloadData];
	
	[self.view.window endSheet:self.renameWindow];
}

- (IBAction) deleteColorList:(id) sender {
	NSBundle * currentBundle = [NSBundle bundleForClass:[self class]];
	CLMenuItem * item = (CLMenuItem *) self.colorListsPopup.selectedItem;
	NSString * path = item.filePath;
	NSAlert * alert = [[NSAlert alloc] init];
	alert.messageText = @"Delete Color Palette?";
	alert.informativeText = [NSString stringWithFormat:@"Are you sure you want to delete %@?",item.colorList.name];
	[alert addButtonWithTitle:@"Delete"];
	[alert addButtonWithTitle:@"Cancel"];
	
	NSString * iconPath = [currentBundle pathForResource:@"ColorListsLargeIcon" ofType:@"tiff"];
	alert.icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
	
	NSInteger result = [alert runModal];
	if(result == NSAlertFirstButtonReturn) {
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	[self reloadColorLists];
}

- (IBAction) importColorList:(id) sender {
	NSOpenPanel * openPanel = [NSOpenPanel openPanel];
	openPanel.canChooseDirectories = FALSE;
	openPanel.canChooseFiles = TRUE;
	NSInteger result = [openPanel runModal];
	NSFileManager * fileManager = [NSFileManager defaultManager];
	if(result) {
		NSString * fileName = [openPanel.URL.path lastPathComponent];
		NSString * title = [fileName stringByDeletingPathExtension];
		NSString * dest = [[NSString stringWithFormat:@"~/Library/Colors/%@",fileName] stringByExpandingTildeInPath];
		
		//try and load NSColorList.
		NSColorList * colorList = [[NSColorList alloc] initWithName:title fromFile:openPanel.URL.path];
		if(!colorList) {
			return;
		}
		
		[fileManager copyItemAtPath:openPanel.URL.path toPath:dest error:nil];
		[self refresh];
		if([self.colorListsPopup itemWithTitle:title]) {
			[self.colorListsPopup selectItemWithTitle:title];
			[self.tableView reloadData];
		}
	}
}

- (IBAction) revealInFinder:(id) sender {
	CLMenuItem * item = (CLMenuItem *)self.colorListsPopup.selectedItem;
	NSArray * urls = @[item.filePath];
	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
}

#pragma mark Table View stuff

- (void) keyDown:(NSEvent *)theEvent {
	if(theEvent.keyCode == 51) {
		CLMenuItem * item = (CLMenuItem *)self.colorListsPopup.selectedItem;
		if(self.tableView.selectedRow > item.colorList.allKeys.count) {
			NSBeep();
			return;
		}
		ColorListsTableCellView * cellView = [self.tableView viewAtColumn:0 row:self.tableView.selectedRow makeIfNecessary:FALSE];
		if(cellView) {
			[item.colorList removeColorWithKey:cellView.label.stringValue];
		}
		[item.colorList writeToFile:item.filePath];
		[self.tableView reloadData];
	}
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
	CLMenuItem * menuItem = (CLMenuItem *)[self.colorListsPopup selectedItem];
	return [menuItem.colorList allKeys].count;
}

- (NSView *) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	ColorListsTableCellView * cell = [tableView makeViewWithIdentifier:@"ColorListsTableCellView" owner:nil];
	CLMenuItem * item = (CLMenuItem *)[self.colorListsPopup selectedItem];
	NSColorList * colorList = item.colorList;
	NSString * key = [[self sortedKeysForColorList:colorList] objectAtIndex:row];
	cell.label.stringValue = key;
	cell.colorView.wantsLayer = TRUE;
	cell.colorView.layer.backgroundColor = [[colorList colorWithKey:key] CGColor];
	cell.filePath = item.filePath;
	cell.colorList = colorList;
	return cell;
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
	NSInteger row = self.tableView.selectedRow;
	CLMenuItem * item = (CLMenuItem *)[self.colorListsPopup selectedItem];
	NSColorList * colorList = item.colorList;
	NSArray * keys = [self sortedKeysForColorList:colorList];
	if(row > keys.count-1) {
		return;
	}
	NSString * key = [keys objectAtIndex:row];
	NSColor * color = [colorList colorWithKey:key];
	[self.main setColor:color];
}

- (NSDragOperation) tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
	NSLog(@"validateDrop %@",info);
	[tableView setDropRow:self.tableView.numberOfRows dropOperation:dropOperation];
	return NSDragOperationGeneric;
}

- (BOOL) tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
	NSLog(@"dropOperation %@",info);
	
	if([[info draggingPasteboard].types containsObject:NSColorPboardType]) {
		NSColor * color = [NSColor colorFromPasteboard:[info draggingPasteboard]];
		
		CLMenuItem * item = (CLMenuItem *)self.colorListsPopup.selectedItem;
		NSColorList * list = item.colorList;
		NSString * untitledKey = @"Untitled";
		
		if([list colorWithKey:untitledKey]) {
			//find next possible key
			NSUInteger i = 1;
			BOOL foundKey = FALSE;
			while(!foundKey) {
				untitledKey = [NSString stringWithFormat:@"Untitled %lu",i];
				if(![list colorWithKey:untitledKey]) {
					foundKey = TRUE;
				}
				i++;
				
			}
		}
		
		[list setColor:color forKey:untitledKey];
		[self.tableView reloadData];
		[list writeToFile:item.filePath];
		
		return TRUE;
	}
	
	return FALSE;
}

@end
