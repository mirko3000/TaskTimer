//
//  TimeIntervalFormatter.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 07.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "TimeIntervalFormatter.h"

@implementation TimeIntervalFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    
    if (![anObject isKindOfClass:[NSNumber class]]) {
        return nil;
    }

    double interval = [anObject doubleValue];
    
    int seconds = ((int) interval) % 60;
    int minutes = ((int) (interval - seconds) / 60) % 60;
    int hours = ((int) interval - seconds - (60 * minutes)) / 3600;
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours, minutes, seconds];
    
}

@end
