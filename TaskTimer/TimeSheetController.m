//
//  TimeSheetController
//  TaskTimer
//
//  Created by Mirko Bleyh on 14.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "TimeSheetController.h"
#import "ScrollingTextView.h"

@implementation TimeSheetController


-(id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    
    if (self) {
        

    }
    
    return self;
}



-(void)windowDidLoad {
    [super windowDidLoad];
    
    [self removeTableColumns];
    
    [self buildTableColumn:@"01.03.13"];
    [self buildTableColumn:@"02.03.13"];
    [self buildTableColumn:@"03.03.13"];
    [self buildTableColumn:@"04.03.13"];
    [self buildTableColumn:@"05.03.13"];
    [self buildTableColumn:@"06.03.13"];
    [self buildTableColumn:@"07.03.13"];
    [self buildTableColumn:@"08.03.13"];
    [self buildTableColumn:@"09.03.13"];
    [self buildTableColumn:@"10.03.13"];
    [self buildTableColumn:@"11.03.13"];
    [self buildTableColumn:@"12.03.13"];
    
    [table reloadData];
    
    
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
}



-(IBAction) selectClicked:(id)sender {
   
    [self removeTableColumns];
    
    NSDate *fromDate = [fromDatePicker dateValue];
    NSDate *toDate = [toDatePicker dateValue];
    
    NSDate *loopDate = [fromDate copy];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    
    while (![loopDate isGreaterThan:toDate]) {
        [self buildTableColumn:[dateFormatter stringFromDate:loopDate]];
        loopDate = [loopDate dateByAddingTimeInterval:60*60*24];
    }
    
    
    [table reloadData];
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return 5;
}



- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return @"TestContent";
}


- (void) removeTableColumns {
    
    while([[table tableColumns] count] > 0) {
        [table removeTableColumn:[[table tableColumns] lastObject]];
    }    
}




- (void) buildTableColumn: (NSString *) name;
{
	NSTableColumn *newColumn = [[NSTableColumn alloc] initWithIdentifier: name];
	[[newColumn headerCell] setStringValue: name];
    
	NSCell *textCell = [[NSTextFieldCell alloc] init];
	[textCell setControlSize: NSSmallControlSize];
	[textCell setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSSmallControlSize]]];
	[textCell setEditable: YES];
	[newColumn setDataCell: textCell];
    [newColumn setWidth:52.0];
    
	[table addTableColumn: newColumn];
    
    
}


@end
