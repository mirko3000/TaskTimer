//
//  TimeSheetController
//  TaskTimer
//
//  Created by Mirko Bleyh on 14.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ScrollingTextView;

@interface TimeSheetController : NSWindowController <NSTableViewDataSource, NSApplicationDelegate> {
    IBOutlet NSTableView *table;
    IBOutlet ScrollingTextView *scrollTest;
    
}

-(IBAction) selectClicked:(id)sender;


@end
