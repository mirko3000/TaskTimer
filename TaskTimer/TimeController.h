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
    
    IBOutlet NSTabViewItem *monthView;
    IBOutlet NSTabViewItem *weekView;
    IBOutlet NSTabViewItem *dayView;
    
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *previousButton;
    
    IBOutlet MSZLinkedView *currentView;
    IBOutlet MSZLinkedView *view;
    
    CATransition *transition;
}

@property(retain)MSZLinkedView *currentView;
@property(retain)MSZLinkedView *view;


-(IBAction)nextView:(id)sender;
-(IBAction)previousView:(id)sender;

-(void) setData:(NSArray*)timeArray;

@end
