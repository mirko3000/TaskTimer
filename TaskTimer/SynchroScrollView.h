//
//  SynchroScrollView.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 20.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SynchroScrollView : NSScrollView {
    NSScrollView* synchronizedScrollView; // not retained
    NSMutableArray *horizontalSynchedScrollViews;
    NSMutableArray *verticalSynchedScrollViews;
}

- (void)addSynchronizedScrollView:(NSScrollView*)scrollview verticalScroll:(BOOL)vertical horizontalScroll:(BOOL)horizontal;
- (void)removeSynchronizedScrollView:(NSScrollView*)scrollview verticalScroll:(BOOL)vertical horizontalScroll:(BOOL)horizontal;
- (void)setSynchronizedScrollView:(NSScrollView*)scrollview;
- (void)stopSynchronizing;
- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification;

@end