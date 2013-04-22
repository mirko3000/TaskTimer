//
//  TimeSheetController
//  TaskTimer
//
//  Created by Mirko Bleyh on 14.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ScrollingTextView;
@class SynchroScrollView;

@interface TimeSheetController : NSWindowController <NSTableViewDataSource, NSApplicationDelegate, NSTableViewDelegate> {
    IBOutlet NSTableView *table;
    IBOutlet NSTableView *headerTable;
    IBOutlet SynchroScrollView *tableScrollView;
    IBOutlet SynchroScrollView *headerTableScrollView;
    
    IBOutlet NSTableView *footerTable;
    IBOutlet NSTableView *footerHeaderTable;
    IBOutlet SynchroScrollView *footerTableScrollView;
    IBOutlet SynchroScrollView *footerHeaderTableScrollView;
    
    IBOutlet NSDatePicker *fromDatePicker;
    IBOutlet NSDatePicker *toDatePicker;
    
    IBOutlet NSButton *hideEmptyRadioButton;
}

-(IBAction) selectClicked:(id)sender;
-(void) setData:(NSArray*)timeArray;


@end
