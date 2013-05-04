//
//  MonthViewController.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 04.05.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MSZLinkedView;

@interface MonthViewController : NSViewController


@property MSZLinkedView *linkedView;

-(void) setData:(NSMutableArray*)timeArray withFooter:(NSMutableDictionary*)footerArray;

@end
