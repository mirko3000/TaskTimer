//
//  MSZLinkedView.m
//  CoreAnimationWizard
//
//  Created by Marcus S. Zarra on 3/1/08.
//  Copyright 2008 Zarra Studios LLC. All rights reserved.
//

#import "MSZLinkedView.h"
#import "TimeIntervalFormatter.h"

@implementation MSZLinkedView

@synthesize nextView, previousView, label, mainTable, footerTable, startDate, endDate, dateInterval;

const int MONTH = 1;
const int WEEK = 2;
const int DAY = 3;

NSDateFormatter *weekDateFormatter;
NSDateFormatter *monthDateFormatter;
TimeIntervalFormatter *timeFormatter;

- (void)awakeFromNib
{
    [self setWantsLayer:YES];
    
    timeFormatter = [[TimeIntervalFormatter alloc] init];
    startDate = [[NSDate alloc] init];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:startDate];
    
    // Get the monday of the current week
    [comps setWeekday:2];
    startDate = [cal dateFromComponents:comps];
    
    //Get the sunday of the current week
    [comps setWeekday:1];
    endDate = [cal dateFromComponents:comps];
    
    weekDateFormatter = [[NSDateFormatter alloc] init];
    [weekDateFormatter setDateFormat:@"dd.MM.yy"];
    
    monthDateFormatter = [[NSDateFormatter alloc] init];
    [monthDateFormatter setDateFormat:@"MM.yyyy"];
    
    //[label setStringValue:[[[weekDateFormatter stringFromDate:startDate] stringByAppendingString:@" - "] stringByAppendingString:[weekDateFormatter stringFromDate:endDate]]];
    
    //[self updateTableHeaders];
}


-(void)updateLabel {
    
    if (dateInterval == MONTH) {
        [label setStringValue:[monthDateFormatter stringFromDate:startDate]];
    }
    else if (dateInterval == WEEK) {
        [label setStringValue:[[[weekDateFormatter stringFromDate:startDate] stringByAppendingString:@" - "] stringByAppendingString:[weekDateFormatter stringFromDate:endDate]]];
        
    }
    else {
        //TODO
    }
    
}


// This operation updates the table headers with the dates
// of the currently selected timespan
-(void) updateTableHeaders {
    
    if (dateInterval == MONTH) {
        // First remove all date columns (except first task column)
        while([[mainTable tableColumns] count] > 1) {
            [mainTable removeTableColumn:[[mainTable tableColumns] lastObject]];
        }
        while([[footerTable tableColumns] count] > 1) {
            [footerTable removeTableColumn:[[footerTable tableColumns] lastObject]];
        }
        
        // Now add a single Month column
        [self buildTableColumn:[monthDateFormatter stringFromDate:startDate]];
        
    }
    else if (dateInterval == WEEK) {
    
    
        // First remove all date columns (except first task column)
        while([[mainTable tableColumns] count] > 1) {
            [mainTable removeTableColumn:[[mainTable tableColumns] lastObject]];
        }
        while([[footerTable tableColumns] count] > 1) {
            [footerTable removeTableColumn:[[footerTable tableColumns] lastObject]];
        }

        // Now create column for each day between start and end
        
        NSDate *loopDate = [startDate copy];
        
        while (![loopDate isGreaterThan:endDate]) {
            
            [self buildTableColumn:[weekDateFormatter stringFromDate:loopDate]];
            loopDate = [loopDate dateByAddingTimeInterval:60*60*24];
        }
    
    }
    else {
        //TODO
    }
    
    [mainTable reloadData];
    [footerTable reloadData];
}



- (void) buildTableColumn: (NSString *) name;
{
	NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier: name];
	[[newColumn headerCell] setStringValue: name];
    
	NSCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setControlSize: NSSmallControlSize];
	[textCell setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSSmallControlSize]]];
	[textCell setEditable: NO];
    
    //NSCell *headerCell = [[NSTextFieldCell alloc] init];
    //[headerCell ];
    //[newColumn setHeaderCell:headerCell];
    
	[newColumn setDataCell: textCell];
    if (dateInterval == WEEK) {
        [newColumn setWidth:60.0];
    }
    else if (dateInterval == MONTH) {
        [newColumn setWidth:120.0];
    }
    else {
        [newColumn setWidth:120.0];
    }
    
    [textCell setFormatter:timeFormatter];
    
	[mainTable addTableColumn: newColumn];
    [footerTable addTableColumn: newColumn];
    
}


@end
