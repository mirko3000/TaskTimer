//
//  TimeController.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 23.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "TimeController.h"
#import "MSZLinkedView.h"
#import "TaskResult.h"

@implementation TimeController

@synthesize currentView, view;

// Calendar stuff
NSCalendar *cal;
NSDateFormatter *dateFormatter;

// Data for the tables
NSMutableDictionary *dataDict;
NSMutableDictionary *footerDict;
NSMutableArray *dataSet;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    cal = [NSCalendar currentCalendar];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    
    return self;
}




-(void)windowDidLoad {
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [view setWantsLayer:YES];
    [view addSubview:[self currentView]];
    
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromLeft];
    
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [view setAnimations:ani];
    
    [view setStartDate:[[NSDate alloc] init]];
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
        NSLog(@"TimeDict: %@", res);
    }
}


-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (tableView == [currentView mainTable]) {
        
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
    if (aTableView == [currentView mainTable]) {
        return [dataSet count];
    }
    else {
        return 1;
    }
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    TaskResult *dict = [dataSet objectAtIndex:rowIndex];
    
    // Data table
    if (aTableView == [currentView mainTable]) {
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
            return [footerDict objectForKey:[aTableColumn identifier]];
        }
    }
    
    return @"<empty>";
}



- (void)setNewCurrentView:(MSZLinkedView*)newView
{
    if (!currentView) {
        currentView = newView;
        return;
    }
    //NSView *contentView = [[self window] contentView];
    [[view animator] replaceSubview:currentView with:newView];
    
    //[[contentView animator] replaceSubview:currentView with:newView];
    currentView = newView;
    
    [[currentView label]  setStringValue:[[[dateFormatter stringFromDate:[currentView startDate]] stringByAppendingString:@" - "] stringByAppendingString:[dateFormatter stringFromDate:[currentView endDate]]]];

    [currentView updateTableHeaders];
    
}


- (IBAction)nextView:(id)sender;
{
    
    // Transition from right
    [transition setSubtype:kCATransitionFromRight];
    
    MSZLinkedView *curView = [self currentView];
    MSZLinkedView *nexView = [curView nextView];
    MSZLinkedView *prevView = [curView previousView];
    
    // Calculate new dates
    NSDate *currentStartDate = [[curView startDate] copy];
    NSDate *currentEndDate = [[curView endDate] copy];
    currentStartDate = [currentStartDate dateByAddingTimeInterval:60*60*24*7];
    currentEndDate = [currentEndDate dateByAddingTimeInterval:60*60*24*7];
    [nexView setStartDate:currentStartDate];
    [nexView setEndDate:currentEndDate];
    
    [self setNewCurrentView:nexView];
    
    //update new next and previous
    [nexView setNextView:prevView];
    [nexView setPreviousView:curView];
    
}


- (IBAction)previousView:(id)sender;
{
    [transition setSubtype:kCATransitionFromLeft];
    
    MSZLinkedView *curView = [self currentView];
    MSZLinkedView *nexView = [curView nextView];
    MSZLinkedView *prevView = [curView previousView];
    
    // Calculate new dates
    NSDate *currentStartDate = [[curView startDate] copy];
    NSDate *currentEndDate = [[curView endDate] copy];
    currentStartDate = [currentStartDate dateByAddingTimeInterval:60*60*24*7*-1];
    currentEndDate = [currentEndDate dateByAddingTimeInterval:60*60*24*7*-1];
    [prevView setStartDate:currentStartDate];
    [prevView setEndDate:currentEndDate];
    
    [self setNewCurrentView:prevView];
    
    //update new next and previous
    [prevView setNextView:curView];
    [prevView setPreviousView:nexView];
}



@end
