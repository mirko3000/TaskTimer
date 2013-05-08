//
//  TimeDataManager.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 04.05.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TaskResult;

@interface TimeDataManager : NSObject

-(void)addTimeEntry:(NSManagedObject*)time;

-(void)addToWeekData:(NSManagedObject*) time;
-(void)addToMonthData:(NSManagedObject*) time;

-(NSMutableArray*) getMonthData;
-(NSMutableDictionary*) getMonthSumData;
-(NSMutableArray*) getWeekData2;
-(NSMutableDictionary*) getWeekSumData;


@end
