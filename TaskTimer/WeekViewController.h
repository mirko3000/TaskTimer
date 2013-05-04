//
//  WeekViewController.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 04.05.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSZLinkedView.h"

@interface WeekViewController : NSViewController  <NSTableViewDataSource>

@property MSZLinkedView *linkedView;


-(void) setData:(NSMutableArray*)timeArray withFooter:(NSMutableDictionary*)footerArray;

@end
