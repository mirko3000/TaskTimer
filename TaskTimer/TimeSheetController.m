//
//  TimeSheetController
//  TaskTimer
//
//  Created by Mirko Bleyh on 14.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "TimeSheetController.h"
#import "ScrollingTextView.h"
#import "TaskResult.h"
#import "TimeIntervalFormatter.h"
#import "SynchroScrollView.h"

@implementation TimeSheetController

NSMutableDictionary *dataDict;
NSMutableDictionary *footerDict;
NSMutableArray *dataSet;
//NSMutableArray *footerSet;

TimeIntervalFormatter *timeFormatter;


-(id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    
    if (self) {
        timeFormatter = [[TimeIntervalFormatter alloc] init];
    
    }
    
    return self;
}



-(void)windowDidLoad {
    [super windowDidLoad];
    
    [self removeTableColumns];    
    
    NSDate *firstDayOfMonth = [[NSDate alloc] init];
    NSDate *lastDayOfMonth = [[NSDate alloc] init];
    
    
    // calculate first day
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:firstDayOfMonth];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [cal dateFromComponents:comp];
    
    // for the last day first add one month, then substract one day
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    NSDate *beginningOfNextMonth = [cal dateByAddingComponents:comps toDate:firstDayOfMonthDate options:0];
    
    lastDayOfMonth = [beginningOfNextMonth dateByAddingTimeInterval:-(24*60)];
    
    [fromDatePicker setDateValue:firstDayOfMonthDate];
    [toDatePicker setDateValue:lastDayOfMonth];
    
    // Set up vertikal (up/down) scrolling synchro
    [headerTableScrollView addSynchronizedScrollView:tableScrollView verticalScroll:YES horizontalScroll:NO];
    [tableScrollView addSynchronizedScrollView:headerTableScrollView verticalScroll:YES horizontalScroll:NO];

    
    // Set up horizontal (right/left) scrolling synchro
    [footerTableScrollView addSynchronizedScrollView:tableScrollView verticalScroll:NO horizontalScroll:YES];
    [tableScrollView addSynchronizedScrollView:footerTableScrollView verticalScroll:NO horizontalScroll:YES];
    
}



-(void) setData:(NSArray *)timeArray {
    
    // Init data map
    dataDict = [[NSMutableDictionary alloc] init];
    footerDict = [[NSMutableDictionary alloc] init];
    
    // For each day calculate the sum of each task and the total sum of the day
    for (NSManagedObject *time in timeArray ) {
        
        //NSManagedObject *task = [time valueForKey:@"task"];
        //NSString *taskName = [task valueForKey:@"name"];
        NSDate *start = [time valueForKey:@"start"];
        //NSDate *end = [time valueForKey:@"end"];
        NSNumber *duration = [time valueForKey:@"duration"];
        
        // check if start and end is on the same day
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDateComponents *startComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:start];
        NSDateComponents *endComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:start];
        
        NSString *dateStringKey = [[NSMutableString alloc] init];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"dd.MM.YY"];
        dateStringKey = [dateFormatter stringFromDate:start];
        
        //NSLog(@"Key: %@", dateStringKey);
        
        if ([startComponents isEqualTo:endComponents]) {
            
            
            // 1) First get the taks array
            NSMutableDictionary *dataForTaskArray;
            NSNumber *taskDayTime;
            
            if ([dataDict objectForKey:[[time valueForKey:@"task"] valueForKey:@"name"]] != NULL) {
                dataForTaskArray = [dataDict objectForKey:[[time valueForKey:@"task"] valueForKey:@"name"]];
            }
            else {
                // No entry yet for this task, create new dictionary
                dataForTaskArray = [[NSMutableDictionary alloc] init];
                [dataDict setObject:dataForTaskArray forKey:[[time valueForKey:@"task"] valueForKey:@"name"]];
            }
            
            // 2) Second get the day
            if ([dataForTaskArray objectForKey:dateStringKey] != NULL) {
                //NSLog(@"Date: %@", startComponents);
                taskDayTime = [dataForTaskArray objectForKey:dateStringKey];
            }
            else {
                // No entry yet for this day, create new entry
                taskDayTime = [[NSNumber alloc] initWithDouble:0.0];
            }
            
            // Now add the current timing duration to the time entry
            taskDayTime = [[NSNumber alloc] initWithDouble:([duration doubleValue] + [taskDayTime doubleValue])];
            [dataForTaskArray setObject:taskDayTime forKey:dateStringKey];
            //NSLog(@"New value: %@ for task %@", taskDayTime, taskName);
            
            
            
//            // 3) Last get the day sum entry
//            if ([dataDict objectForKey:@"! SUM"] != NULL) {
//                dataForSumArray = [dataDict objectForKey:@"! SUM"];
//            }
//            else {
//                // No entry yet for this task, create new dictionary
//                dataForSumArray = [[NSMutableDictionary alloc] init];
//                [dataDict setObject:dataForSumArray forKey:@"! SUM"];
//            }
            
            // 4) Get the SUM day
            if ([footerDict objectForKey:dateStringKey] != NULL) {
                //NSLog(@"Date: %@", startComponents);
                taskDayTime = [footerDict objectForKey:dateStringKey];
            }
            else {
                // No entry yet for this day, create new entry
                taskDayTime = [[NSNumber alloc] initWithDouble:0.0];
            }
            
            // Now add the current timing duration to the time entry
            taskDayTime = [[NSNumber alloc] initWithDouble:([duration doubleValue] + [taskDayTime doubleValue])];
            [footerDict setObject:taskDayTime forKey:dateStringKey];
            //NSLog(@"New value: %@ for task %@", taskDayTime, taskName);
        }
    }
    
    // Convert data into NSArray
    dataSet = [[NSMutableArray alloc] init];
    
    NSEnumerator *keyEnum = [dataDict keyEnumerator];
    NSString *key;
    while(key = [keyEnum nextObject]) {
        TaskResult *res = [[TaskResult alloc] init];
        [res setTaskName:key];
        NSDictionary *dict = [[dataDict objectForKey:key] copy];
        [res setTimeDict:dict];
        [dataSet addObject:res];
    }
}



-(IBAction) selectClicked:(id)sender {
   
    [self removeTableColumns];
    
    NSDate *fromDate = [fromDatePicker dateValue];
    NSDate *toDate = [toDatePicker dateValue];
    
    NSDate *loopDate = [fromDate copy];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    
    while (![loopDate isGreaterThan:toDate]) {
        
        if ([hideEmptyRadioButton state] == NSOnState) {
            // Check if values exixt for that date
            NSNumber *d = [footerDict objectForKey:[dateFormatter stringFromDate:loopDate]];
            if (d == 0) {
                loopDate = [loopDate dateByAddingTimeInterval:60*60*24];
                continue;
            }
        }

        [self buildTableColumn:[dateFormatter stringFromDate:loopDate]];
        loopDate = [loopDate dateByAddingTimeInterval:60*60*24];
    }
    

    
    
    [table reloadData];
}


-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == table) {
    
    // Get the date of the column
    NSString *dateString = [tableColumn identifier];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    
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
    if (aTableView == table || aTableView == headerTable) {
        return [dataSet count];
    }
    else {
        return 1;
    }
}



- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    TaskResult *dict = [dataSet objectAtIndex:rowIndex];
    
    // Data table
    if (aTableView == table) {
        return [[dict timeDict] objectForKey:[aTableColumn identifier]];
    }
    // Header table
    else if (aTableView == headerTable) {
        
        return [dict taskName];
    }
    // Footer Header table
    else if (aTableView == footerHeaderTable) {
        return @"Sum";
    }
    // Footer data table
    else {
        return [footerDict objectForKey:[aTableColumn identifier]];
    }
    
    return @"<empty>";
}


- (void) removeTableColumns {
    while([[table tableColumns] count] > 0) {
        [table removeTableColumn:[[table tableColumns] lastObject]];
    }
    while([[footerTable tableColumns] count] > 0) {
        [footerTable removeTableColumn:[[footerTable tableColumns] lastObject]];
    }
}


- (void) createHeaderColumn: (NSString *) name;
{
	NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier: name];
	[[newColumn headerCell] setStringValue: name];
    
	NSCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setControlSize: NSSmallControlSize];
	[textCell setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSSmallControlSize]]];
	[textCell setEditable: NO];
	[newColumn setDataCell: textCell];
    [newColumn setWidth:100.0];
    
	[table addTableColumn: newColumn];
    
}



- (void) buildTableColumn: (NSString *) name;
{
	NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier: name];
	[[newColumn headerCell] setStringValue: name];
    
	NSCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setControlSize: NSSmallControlSize];
	[textCell setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSSmallControlSize]]];
	[textCell setEditable: NO];
	[newColumn setDataCell: textCell];
    [newColumn setWidth:60.0];
    
    [textCell setFormatter:timeFormatter];
    
	[table addTableColumn: newColumn];
    [footerTable addTableColumn: newColumn];
    
}


@end
