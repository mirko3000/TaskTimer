//
//  MSZLinkedView.h
//  CoreAnimationWizard
//
//  Created by Marcus S. Zarra on 3/1/08.
//  Copyright 2008 Zarra Studios LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

@interface MSZLinkedView : NSView {
    
    // Links to next and previous View
    IBOutlet MSZLinkedView *previousView;
    IBOutlet MSZLinkedView *nextView;
    
    IBOutlet NSTextField *label;
    
    IBOutlet NSTableView *mainTable;
    IBOutlet NSTableView *footerTable;
}

-(void) updateTableHeaders;
-(void) updateLabel;

extern int const MONTH;
extern int const WEEK;
extern int const DAY;

@property(retain)MSZLinkedView *previousView, *nextView;
@property NSTextField *label;
@property (retain) NSDate *startDate;
@property (retain) NSDate *endDate;
@property NSTableView *mainTable;
@property NSTableView *footerTable;
@property int dateInterval;

@end
