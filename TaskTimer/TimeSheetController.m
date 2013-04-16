//
//  TimeSheetController
//  TaskTimer
//
//  Created by Mirko Bleyh on 14.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "TimeSheetController.h"
#import "ScrollingTextView.h"

@implementation TimeSheetController


-(id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    
    if (self) {
        // Inialization here...
        //[self createTable];
        [self buildTableColumn:@"Column1"];
        [self buildTableColumn:@"Column2"];
        [self buildTableColumn:@"Column3"];
        
    }
    
    return self;
}



-(void)windowDidLoad {
    [super windowDidLoad];
    
    //[self createTable];
    // Other initialization here...
}

-(IBAction) selectClicked:(id)sender {
   
    [scrollTest setStaticText:@"Kurz"];
    [scrollTest setScrollingText:@"Das ist ein ganz langer Text"];
    [scrollTest setSpeed:0.015];
    
    [scrollTest startAnimation];
    
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return 5;
}



- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return @"TestContent";
}




- (void)createTable
{
    /* We need to remove the dynamic columns corresponding to the old data BEFORE we generate any new data. Removing columns forces a table update which will use cached outline items to get display values. If we dispose the old outline data then the outline has a dangling pointer (bad) */
    [self removeDynamicColumns];
    
    [self addDynamicColumns];
    
    
    [table setNeedsDisplay:YES]; // needed to refresh the number of columns displayed
//    [table setAutoresizesOutlineColumn:NO];
    [table reloadData];
}


- (void)addDynamicColumns
{
    
    
    // determine the column names
    // ...
        // configure the new column
        NSTableColumn* column = [self createTableColumnWithIdentifier:@"Column1" title:@"Column 1"];
        // add it to the table
        [table addTableColumn:column];
    
    NSTableColumn* column2 = [self createTableColumnWithIdentifier:@"Column2" title:@"Column 2"];
    // add it to the table
    [table addTableColumn:column2];
    NSTableColumn* column3 = [self createTableColumnWithIdentifier:@"Column3" title:@"Column 3"];
    // add it to the table
    [table addTableColumn:column3];
        //[table moveColumn:([table numberOfColumns] - 1) toColumn:2];
    
}


- (void)removeDynamicColumns
{
    NSTableColumn* column;
    
    
    // assume the dynamic columns are at the front of the table
    column = [[table tableColumns] objectAtIndex:1];
    //while (![[column identifier] isEqualToString:StaticColumnIdentifier])
   // {
    //    [table removeTableColumn:column];
    //    column = [[table tableColumns] objectAtIndex:1];
   // }
}


- (NSTableColumn*)createTableColumnWithIdentifier:(NSString*) columnIdentifier title:(NSString*)columnTitle
{
    // configure the new column
    NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier:columnIdentifier];
    [column setEditable:NO];
    
    // we do not want the column to resize
    // starting in 10.4, you should use setResizingMask: and not setResizable:
    if ([column respondsToSelector:@selector(setResizingMask:)])
        [column setResizingMask:NSTableColumnNoResizing];
    else
        [column setResizable:NO]; // pre-Tiger
    
  //  [[column headerCell] setFont:[table headerFont]];
    [[column headerCell] setStringValue:columnTitle];
   // [[column dataCell] setFont:[table tableFont]];
   // [self copyColumnConfiguration:column fromColumn:[table tableColumnWithIdentifier:PrototypeColumnIdentifier]];
    
    return column;
}



- (void)copyColumnConfiguration:(NSTableColumn*)dstColumn fromColumn: (NSTableColumn*)srcColumn
{
    id srcCell;
    id dstCell;
    
    srcCell = [srcColumn dataCell];
    dstCell = [dstColumn dataCell];
    [dstCell setAlignment:[srcCell alignment]];
    [dstCell setFormatter:[srcCell formatter]];
    
    
    srcCell = [srcColumn headerCell];
    dstCell = [dstColumn headerCell];
    [dstCell setAlignment:[srcCell alignment]];
}



- (void) buildTableColumn: (NSString *) name;
{
	NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier: name];
	[[newColumn headerCell] setStringValue: name];
    
	NSCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setControlSize: NSSmallControlSize];
	[textCell setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSSmallControlSize]]];
	[textCell setEditable: YES];
	[newColumn setDataCell: textCell];
    
	//[newColumn bind: @"value" toObject: rowsController withKeyPath: [NSString stringWithFormat: @"arrangedObjects.%@", name] options: nil];
    
	[table addTableColumn: newColumn];
    
    NSArray *columns = [table tableColumns];
    for (NSTableColumn *column in columns) {
        NSLog(@"Column: %@", [column identifier]);
    }
    
}


@end
