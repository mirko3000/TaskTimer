//
//  WeekViewController.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 04.05.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "WeekViewController.h"
#import "TaskResult.h"

@implementation WeekViewController

// Calendar stuff
NSCalendar *cal;
NSDateFormatter *dateFormatter;

// Data for the tables
NSMutableDictionary *weekDataDict;
NSMutableDictionary *weekFooterDict;
NSMutableArray *weekDataSet;

@synthesize linkedView;


- (id)init
{
    self = [super init];
    if (self) {
        cal = [NSCalendar currentCalendar];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd.MM.yy"];
    }
    return self;
}



-(void) setData:(NSMutableArray*)timeArray withFooter:(NSMutableDictionary *)footerArray {
    weekDataSet = timeArray;
    weekFooterDict = footerArray;
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
        return [weekDataSet count];
    }
    else {
        return 1;
    }
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    TaskResult *dict = [weekDataSet objectAtIndex:rowIndex];
    
    // Data table
    if (aTableView == [[self getLinkedViewLazy] mainTable]) {
        if ([[aTableColumn identifier] isEqualToString:@"Task"]) {
            return [dict taskName];
        }
        else {
            //NSLog(@"Identifier: %@", [aTableColumn identifier]);
            NSObject *object = [[dict timeDict] objectForKey:[aTableColumn identifier]];
            return object;
        }
        
    }
    // Footer Header table
    else  {
        if ([[aTableColumn identifier] isEqualToString:@"Task"]) {
            return @"SUM";
        }
        else {
            return [weekFooterDict objectForKey:[aTableColumn identifier]];
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
