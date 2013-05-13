//
//  MonthViewController.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 04.05.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "MonthViewController.h"
#import "MSZLinkedView.h"
#import "TaskResult.h"

@implementation MonthViewController

// Calendar stuff
NSCalendar *cal;
NSDateFormatter *dateFormatter;

// Data for the tables
NSMutableDictionary *monthDataDict;
NSMutableDictionary *monthFooterDict;
NSMutableArray *monthDataSet;

@synthesize linkedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



-(void) setData:(NSMutableArray*)timeArray withFooter:(NSMutableDictionary *)footerArray {
    monthDataSet = timeArray;
    monthFooterDict = footerArray;
    [[[self getLinkedViewLazy] mainTable] reloadData];
    [[[self getLinkedViewLazy] footerTable] reloadData];
}



-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == [[self getLinkedViewLazy] mainTable]) {
        
        // Get the date of the column
        NSString *dateString = [tableColumn identifier];
        
        NSDate *date = [dateFormatter dateFromString:dateString ];
        // setting units we would like to use in future
        NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
        
        if ([comps weekday] == 1 || [comps weekday] == 7) {
            [cell setDrawsBackground:YES];
            //NSFont *font = [NSFont systemFontOfSize:14.0];
            [cell setBackgroundColor:[NSColor lightGrayColor]];
            //[[tableColumn headerCell] setBackgroundColor:[NSColor lightGrayColor]];
            [cell setBordered:NO];
        }
        else {
            //[cell setBackgroundColor:[NSColor blueColor]];
        }
    }
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (aTableView == [[self getLinkedViewLazy] mainTable]) {
        return [monthDataSet count];
    }
    else {
        return 1;
    }
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    TaskResult *dict = [monthDataSet objectAtIndex:rowIndex];
    
    // Data table
    if (aTableView == [[self getLinkedViewLazy] mainTable]) {
        if ([[aTableColumn identifier] isEqualToString:@"Task"]) {
            return [dict taskName];
        }
        else {
            return [[dict timeDict] objectForKey:[aTableColumn identifier]];
        }
        
    }
    // Footer Header table
    else  {
        if ([[aTableColumn identifier] isEqualToString:@"Task"]) {
            return @"SUM";
        }
        else {
            return [monthFooterDict objectForKey:[aTableColumn identifier]];
        }
    }
    
    return @"<empty>";
}


-(MSZLinkedView*)getLinkedViewLazy {
    if (linkedView == NULL) {
        linkedView = (MSZLinkedView*)[self view];
    }
    return linkedView;
}

@end
