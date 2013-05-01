//
//  TaskResult.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 19.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "TaskResult.h"

@implementation TaskResult

@synthesize taskName;
@synthesize timeDict;

- (NSString *)description {
    return [NSString stringWithFormat: @"TaskResult: Name=%@ Time=%@", taskName, timeDict];
}

@end
