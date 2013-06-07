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
#import "WeekViewController.h"
#import "MonthViewController.h"
#import "TimeDataManager.h"

@implementation TimeController

@synthesize currentWeekView, weekView, currentMonthView, monthView;

// Calendar stuff
NSCalendar *cal;
NSDateFormatter *dateFormatter;

// Data for the tables
NSMutableDictionary *dataDict;
NSMutableDictionary *footerDict;
NSMutableArray *dataSet;

WeekViewController *weekController;
WeekViewController *weekControllerNext;
WeekViewController *weekControllerPrevious;

MonthViewController *monthController;
MonthViewController *monthControllerNext;
MonthViewController *monthControllerPrevious;

TimeDataManager *dataMgr;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    cal = [NSCalendar currentCalendar];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yy"];
    
    // Initialize the three weeks views
    weekController = [[WeekViewController alloc] initWithNibName:@"WeekView" bundle:nil];
    currentWeekView = (MSZLinkedView*)[weekController view];
    weekControllerNext = [[WeekViewController alloc] initWithNibName:@"WeekView" bundle:nil];
    [currentWeekView setNextView:(MSZLinkedView*)[weekControllerNext view]];
    weekControllerPrevious = [[WeekViewController alloc] initWithNibName:@"WeekView" bundle:nil];
    [currentWeekView setPreviousView:(MSZLinkedView*)[weekControllerPrevious view]];
    
    // Set type
    [currentWeekView setDateInterval:WEEK];
    [[currentWeekView nextView] setDateInterval:WEEK];
    [[currentWeekView previousView] setDateInterval:WEEK];
    
    
    // Initialize the three monts views
    monthController = [[MonthViewController alloc] initWithNibName:@"MonthView" bundle:nil];
    currentMonthView = (MSZLinkedView*)[monthController view];
    monthControllerNext = [[MonthViewController alloc] initWithNibName:@"MonthView" bundle:nil];
    [currentMonthView setNextView:(MSZLinkedView*)[monthControllerNext view]];
    monthControllerPrevious = [[MonthViewController alloc] initWithNibName:@"MonthView" bundle:nil];
    [currentMonthView setPreviousView:(MSZLinkedView*)[monthControllerPrevious view]];
    
    // Set type
    [currentMonthView setDateInterval:MONTH];
    [[currentMonthView nextView] setDateInterval:MONTH];
    [[currentMonthView previousView] setDateInterval:MONTH];

    //[window setContentView:[controller view]];
    
    dataMgr = [[TimeDataManager alloc] init];
    
    return self;
}


-(void)windowDidLoad {
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    // Week Animation
    [weekView setWantsLayer:YES];
    [weekView addSubview:[self currentWeekView]];
    
    transition = [CATransition animation];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromRight];
    [transition setSpeed:0.8];
    
    NSDictionary *ani = [NSDictionary dictionaryWithObject:transition forKey:@"subviews"];
    [weekView setAnimations:ani];
    
    [weekView setStartDate:[[NSDate alloc] init]];
    [weekView setDateInterval:WEEK];
    
    // Month Animation
    [monthView setWantsLayer:YES];
    [monthView addSubview:[self currentMonthView]];
    
    [monthView setAnimations:ani];
    
    NSDate *today = [[NSDate alloc] init];
    
    // calculate first day
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comp = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [cal dateFromComponents:comp];
    
    // for the last day first add one month, then substract one day
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    NSDate *beginningOfNextMonth = [cal dateByAddingComponents:comps toDate:today options:0];
    
    NSDate *lastDayOfMonth = [beginningOfNextMonth dateByAddingTimeInterval:-(24*60)];
    [monthView setStartDate:firstDayOfMonthDate];
    [monthView setEndDate:lastDayOfMonth];
    [monthView setDateInterval:MONTH];
    
    // Update initial content
    [currentWeekView updateTableHeaders];
    [currentMonthView updateTableHeaders];
    [currentWeekView updateLabel];
    [currentMonthView updateLabel];
}



-(void) setData:(NSArray *)timeArray {
    
    // Init data map
    dataDict = [[NSMutableDictionary alloc] init];
    footerDict = [[NSMutableDictionary alloc] init];
    
    [dataMgr reset];
    
    // For each day calculate the sum of each task and the total sum of the day
    for (NSManagedObject *time in timeArray ) {
        [dataMgr addTimeEntry:time];
    }
    
    // set data for the week view controllers
    NSMutableArray *weekData = [dataMgr getWeekData2];
    
    [weekController setData:weekData withFooter:[dataMgr getWeekSumData]];
    [weekControllerNext setData:weekData withFooter:[dataMgr getWeekSumData]];
    [weekControllerPrevious setData:weekData withFooter:[dataMgr getWeekSumData]];

    // set data for the month view controllers    
    NSMutableArray *monthData = [dataMgr getMonthData];
    
    [monthController setData:monthData withFooter:[dataMgr getMonthSumData]];
    [monthControllerNext setData:monthData withFooter:[dataMgr getMonthSumData]];
    [monthControllerPrevious setData:monthData withFooter:[dataMgr getMonthSumData]];
    
    
    
}


- (void)replaceView:(MSZLinkedView*)oldView withView:(MSZLinkedView*)newView fromMasterView:(MSZLinkedView*) masterView
{
    if (!oldView) {
        oldView = newView;
        return;
    }
    
    [[masterView animator] replaceSubview:oldView with:newView];
    oldView = newView;
    
    [oldView updateLabel];
    
    [oldView updateTableHeaders];
    
}


- (IBAction)nextView:(id)sender;
{
    NSLog(@"Next");
    // Transition from right
    [transition setSubtype:kCATransitionFromRight];
    
    // Check which view is active (month, week or day)
    NSTabViewItem *tabViewItemX = [tabView selectedTabViewItem];
    if (tabViewItemX == monthViewItem) {
   
        MSZLinkedView *curView = [self currentMonthView];
        MSZLinkedView *nexView = [curView nextView];
        MSZLinkedView *prevView = [curView previousView];
        
        // Calculate new dates
        NSDate *currentStartDate = [[curView startDate] copy];

        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setMonth:1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* newStartDate = [calendar dateByAddingComponents:dateComponents toDate:currentStartDate options:0];

        // for the last day first add one month, then substract one day
        NSDate *beginningOfNextMonth = [calendar dateByAddingComponents:dateComponents toDate:newStartDate options:0];
        NSDate *lastDayOfMonth = [beginningOfNextMonth dateByAddingTimeInterval:-(24*60)];
        
        [nexView setStartDate:newStartDate];
        [nexView setEndDate:lastDayOfMonth];
        
        //[self setNewCurrentView:nexView];
        [self replaceView:curView withView:nexView fromMasterView:monthView];
        
        //update new next and previous
        [nexView setNextView:prevView];
        [nexView setPreviousView:curView];
        
        currentMonthView = nexView;
        
    }
    
    else if (tabViewItemX == weekViewItem) {
        
        MSZLinkedView *curView = [self currentWeekView];
        MSZLinkedView *nexView = [curView nextView];
        MSZLinkedView *prevView = [curView previousView];
        
        // Calculate new dates
        NSDate *currentStartDate = [[curView startDate] copy];
        NSDate *currentEndDate = [[curView endDate] copy];
        currentStartDate = [currentStartDate dateByAddingTimeInterval:60*60*24*7];
        currentEndDate = [currentEndDate dateByAddingTimeInterval:60*60*24*7];
        [nexView setStartDate:currentStartDate];
        [nexView setEndDate:currentEndDate];
        
        //[self setNewCurrentView:nexView];
        [self replaceView:curView withView:nexView fromMasterView:weekView];
        
        //update new next and previous
        [nexView setNextView:prevView];
        [nexView setPreviousView:curView];
        
        currentWeekView = nexView;
    }
    else {
        // TODO
    }
    
}


- (IBAction)previousView:(id)sender;
{
    NSLog(@"Previous");
    [transition setSubtype:kCATransitionFromLeft];
    
    // Check which view is active (month, week or day)
    NSTabViewItem *tabViewItemX = [tabView selectedTabViewItem];
    if (tabViewItemX == monthViewItem) {
        MSZLinkedView *curView = [self currentMonthView];
        MSZLinkedView *nexView = [curView nextView];
        MSZLinkedView *prevView = [curView previousView];
        
        // Calculate new dates
        NSDate *currentStartDate = [[curView startDate] copy];
        
        NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
        [dateComponents setMonth:-1];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate* newStartDate = [calendar dateByAddingComponents:dateComponents toDate:currentStartDate options:0];
        
        // for the last day first add one month, then substract one day
        NSDate *beginningOfNextMonth = [calendar dateByAddingComponents:dateComponents toDate:newStartDate options:0];
        NSDate *lastDayOfMonth = [beginningOfNextMonth dateByAddingTimeInterval:-(24*60)];
        
        [prevView setStartDate:newStartDate];
        [prevView setEndDate:lastDayOfMonth];
        
        //[self setNewCurrentView:prevView];
        [self replaceView:curView withView:prevView fromMasterView:monthView];
        
        //update new next and previous
        [prevView setNextView:curView];
        [prevView setPreviousView:nexView];
        
        currentMonthView = prevView;
        
    }
    
    else if (tabViewItemX == weekViewItem) {
        MSZLinkedView *curView = [self currentWeekView];
        MSZLinkedView *nexView = [curView nextView];
        MSZLinkedView *prevView = [curView previousView];
        
        // Calculate new dates
        NSDate *currentStartDate = [[curView startDate] copy];
        NSDate *currentEndDate = [[curView endDate] copy];
        currentStartDate = [currentStartDate dateByAddingTimeInterval:60*60*24*7*-1];
        currentEndDate = [currentEndDate dateByAddingTimeInterval:60*60*24*7*-1];
        [prevView setStartDate:currentStartDate];
        [prevView setEndDate:currentEndDate];
        
        //[self setNewCurrentView:prevView];
        [self replaceView:curView withView:prevView fromMasterView:weekView];
        
        //update new next and previous
        [prevView setNextView:curView];
        [prevView setPreviousView:nexView];
        
        currentWeekView = prevView;
    }
    
    else {
        //TODO
    }
    
    

}



@end
