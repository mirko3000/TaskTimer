//
//  TimeController.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 23.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

@class MSZLinkedView;

@interface TimeController : NSWindowController <NSTableViewDataSource, NSApplicationDelegate, NSTableViewDelegate> {
    
    IBOutlet NSTabView *tabView;
    
    IBOutlet NSTabViewItem *monthViewItem;
    IBOutlet NSTabViewItem *weekViewItem;
    IBOutlet NSTabViewItem *dayViewItem;
    
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *previousButton;
    
    IBOutlet MSZLinkedView *currentWeekView;
    IBOutlet MSZLinkedView *weekView;
    
    IBOutlet MSZLinkedView *currentMonthView;
    IBOutlet MSZLinkedView *monthView;
    
    CATransition *transition;
}

@property(retain)MSZLinkedView *currentWeekView;
@property(retain)MSZLinkedView *weekView;
@property(retain)MSZLinkedView *currentMonthView;
@property(retain)MSZLinkedView *monthView;


-(IBAction)nextView:(id)sender;
-(IBAction)previousView:(id)sender;

-(void) setData:(NSArray*)timeArray;

@end
