//
//  TaskResult.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 19.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskResult : NSObject {
    NSString *taskName;
    NSDictionary *timeDict;
}

@property (nonatomic, copy) NSString * taskName;
@property (nonatomic) NSDictionary * timeDict;

@end
