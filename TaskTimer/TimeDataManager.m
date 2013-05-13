//
//  TimeDataManager.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 04.05.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "TimeDataManager.h"
#import "TaskResult.h"

@implementation TimeDataManager


// Data for the tables
NSMutableDictionary *weekTaskDict;
NSMutableDictionary *weekSumDict;

NSMutableDictionary *monthTaskDict;
NSMutableDictionary *monthSumDict;

// Result data sets
NSMutableArray *monthDataSet;
NSMutableArray *weekDataSet;


- (id)init
{
    self = [super init];
    if (self) {
        weekTaskDict = [[NSMutableDictionary alloc] init];
        weekSumDict = [[NSMutableDictionary alloc] init];
        monthTaskDict = [[NSMutableDictionary alloc] init];
        monthSumDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}


-(void)addTimeEntry:(NSManagedObject*)time {
    
    NSDate *start = [time valueForKey:@"start"];
    
    // check if start and end is on the same day
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *startComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:start];
    NSDateComponents *endComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:start];
    
    if ([startComponents isEqualTo:endComponents]) {
        
        [self addToWeekData:time];
        [self addToMonthData:time];
        
    }
    else {
        //TODO
    }
}


-(void)addToWeekData:(NSManagedObject*) time {
    
    NSDate *start = [time valueForKey:@"start"];
    NSNumber *duration = [time valueForKey:@"duration"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd.MM.YY"];
    NSString *dateStringKey = [dateFormatter stringFromDate:start];
    
    //*************************************
    // 1) First get the taks array:
    //    Contains an array with daily values
    //*************************************
    NSMutableDictionary *dataForTaskArray;
    NSNumber *taskDayTime;
    
    if ([weekTaskDict objectForKey:[[time valueForKey:@"task"] valueForKey:@"name"]] != NULL) {
        dataForTaskArray = [weekTaskDict objectForKey:[[time valueForKey:@"task"] valueForKey:@"name"]];
    }
    else {
        // No entry yet for this task, create new dictionary
        dataForTaskArray = [[NSMutableDictionary alloc] init];
        [weekTaskDict setObject:dataForTaskArray forKey:[[time valueForKey:@"task"] valueForKey:@"name"]];
    }
    
    
    //*************************************
    // 2) Second get the day within the array
    //*************************************
    if ([dataForTaskArray objectForKey:dateStringKey] != NULL) {
        taskDayTime = [dataForTaskArray objectForKey:dateStringKey];
    }
    else {
        // No entry yet for this day, create new entry
        taskDayTime = [[NSNumber alloc] initWithDouble:0.0];
    }

    
    //*************************************
    // 3) Now add the current timing duration to the time entry
    //*************************************
    taskDayTime = [[NSNumber alloc] initWithDouble:([duration doubleValue] + [taskDayTime doubleValue])];
    [dataForTaskArray setObject:taskDayTime forKey:dateStringKey];
    
    
    
    //*************************************
    // 4) Get the SUM day
    //*************************************
    if ([weekSumDict objectForKey:dateStringKey] != NULL) {
        //NSLog(@"Date: %@", startComponents);
        taskDayTime = [weekSumDict objectForKey:dateStringKey];
    }
    else {
        // No entry yet for this day, create new entry
        taskDayTime = [[NSNumber alloc] initWithDouble:0.0];
    }
    
    
    //*************************************
    // 5) Now add the current timing duration to the time entry
    //*************************************
    taskDayTime = [[NSNumber alloc] initWithDouble:([duration doubleValue] + [taskDayTime doubleValue])];
    [weekSumDict setObject:taskDayTime forKey:dateStringKey];

}



-(void)addToMonthData:(NSManagedObject*) time {

    NSDate *start = [time valueForKey:@"start"];
    NSNumber *duration = [time valueForKey:@"duration"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM.YYYY"];
    NSString *dateStringKey = [dateFormatter stringFromDate:start];
    
    
    //*************************************
    // 1) First get the taks array
    //    Contains an array with monthly values
    //*************************************
    NSMutableDictionary *dataForTaskArray;
    NSNumber *taskMonthTime;
    
    if ([monthTaskDict objectForKey:[[time valueForKey:@"task"] valueForKey:@"name"]] != NULL) {
        dataForTaskArray = [monthTaskDict objectForKey:[[time valueForKey:@"task"] valueForKey:@"name"]];
    }
    else {
        // No entry yet for this task, create new dictionary
        dataForTaskArray = [[NSMutableDictionary alloc] init];
        [monthTaskDict setObject:dataForTaskArray forKey:[[time valueForKey:@"task"] valueForKey:@"name"]];
    }
    
    
    //*************************************
    // 2) Second get the month within the array
    //*************************************
    if ([dataForTaskArray objectForKey:dateStringKey] != NULL) {
        taskMonthTime = [dataForTaskArray objectForKey:dateStringKey];
    }
    else {
        // No entry yet for this day, create new entry
        taskMonthTime = [[NSNumber alloc] initWithDouble:0.0];
    }
    
    
    //*************************************
    // 3) Now add the current timing duration to the time entry
    //*************************************
    taskMonthTime = [[NSNumber alloc] initWithDouble:([duration doubleValue] + [taskMonthTime doubleValue])];
    [dataForTaskArray setObject:taskMonthTime forKey:dateStringKey];
    
    
    //*************************************
    // 4) Get the SUM day
    //*************************************
    if ([monthSumDict objectForKey:dateStringKey] != NULL) {
        taskMonthTime = [monthSumDict objectForKey:dateStringKey];
    }
    else {
        // No entry yet for this day, create new entry
        taskMonthTime = [[NSNumber alloc] initWithDouble:0.0];
    }
    
    
    //*************************************
    // 5) Now add the current timing duration to the time entry
    //*************************************
    taskMonthTime = [[NSNumber alloc] initWithDouble:([duration doubleValue] + [taskMonthTime doubleValue])];
    [monthSumDict setObject:taskMonthTime forKey:dateStringKey];
    
}


-(NSMutableArray*) getMonthData {
    
    if (!monthDataSet) {
        // Convert data into NSArray
        monthDataSet = [[NSMutableArray alloc] init];
    
        NSEnumerator *monthKeyEnum = [monthTaskDict keyEnumerator];
        NSString *monthKey;
        while(monthKey = [monthKeyEnum nextObject]) {
            TaskResult *monthRes = [[TaskResult alloc] init];
            [monthRes setTaskName:monthKey];
            NSDictionary *dict = [[monthTaskDict objectForKey:monthKey] copy];
            [monthRes setTimeDict:dict];
            [monthDataSet addObject:monthRes];
        }
    }

    return monthDataSet;
}



-(NSMutableDictionary*) getMonthSumData {
    return monthSumDict;
}



-(NSMutableArray*) getWeekData2 {
    NSLog(@"Start");
    if (!weekDataSet) {
    
        // Convert data into NSArray
        weekDataSet = [[NSMutableArray alloc] init];
        
        NSEnumerator *weekKeyEnum = [weekTaskDict keyEnumerator];
        NSString *weekKey;
        while(weekKey = [weekKeyEnum nextObject]) {
            TaskResult *weekRes = [[TaskResult alloc] init];
            [weekRes setTaskName:weekKey];
            NSDictionary *dict = [[weekTaskDict objectForKey:weekKey] copy];
            [weekRes setTimeDict:dict];
            [weekDataSet addObject:weekRes];
        }
    }

    return weekDataSet;
}



-(NSMutableDictionary*) getWeekSumData {
    return weekSumDict;
}



-(void) reset {
    [weekDataSet removeAllObjects];
    [monthDataSet removeAllObjects];
    
    [weekTaskDict removeAllObjects];
    [weekSumDict removeAllObjects];
    
    [monthTaskDict removeAllObjects];
    [monthSumDict removeAllObjects];
    
    weekDataSet = NULL;
    monthDataSet = NULL;
}


@end
