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

@synthesize nextView, previousView, label, mainTable, footerTable, startDate, endDate;

NSDateFormatter *dateFormatter;
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
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    
    [label setStringValue:[[[dateFormatter stringFromDate:startDate] stringByAppendingString:@" - "] stringByAppendingString:[dateFormatter stringFromDate:endDate]]];
    
    [self updateTableHeaders];
}


// This operation updates the table headers with the dates
// of the currently selected timespan
-(void) updateTableHeaders {
    
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
        
        [self buildTableColumn:[dateFormatter stringFromDate:loopDate]];
        loopDate = [loopDate dateByAddingTimeInterval:60*60*24];
    }
    
    [mainTable reloadData];
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
    [newColumn setWidth:60.0];
    
    [textCell setFormatter:timeFormatter];
    
	[mainTable addTableColumn: newColumn];
    [footerTable addTableColumn: newColumn];
    
}


@end
