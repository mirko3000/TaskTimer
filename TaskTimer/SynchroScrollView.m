//
//  SynchroScrollView.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 20.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "SynchroScrollView.h"

@implementation SynchroScrollView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        verticalSynchedScrollViews = [[NSMutableArray alloc] init];
        horizontalSynchedScrollViews = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}


- (void)addSynchronizedScrollView:(NSScrollView*)scrollView verticalScroll:(BOOL)vertical horizontalScroll:(BOOL)horizontal
{
    NSView *synchronizedContentView;
    
    if (horizontalSynchedScrollViews == NULL) {
        horizontalSynchedScrollViews = [[NSMutableArray alloc] init];
    }
    if (verticalSynchedScrollViews == NULL) {
        verticalSynchedScrollViews = [[NSMutableArray alloc] init];
    }
    
    // stop an existing scroll view synchronizing
    //[self stopSynchronizing];
    
    // don't retain the watched view, because we assume that it will
    // be retained by the view hierarchy for as long as we're around.
    if (vertical) {
        [verticalSynchedScrollViews addObject:[scrollView contentView]];
    }
    if (horizontal) {
        [horizontalSynchedScrollViews addObject:[scrollView contentView]];
    }
    
    // get the content view of the
    synchronizedContentView=[scrollView contentView];
    
    // Make sure the watched view is sending bounds changed
    // notifications (which is probably does anyway, but calling
    // this again won't hurt).
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
    
    // a register for those notifications on the synchronized content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:synchronizedContentView];
}




- (void)setSynchronizedScrollView:(NSScrollView*)scrollview
{
    NSView *synchronizedContentView;
    
    // stop an existing scroll view synchronizing
    [self stopSynchronizing];
    
    // don't retain the watched view, because we assume that it will
    // be retained by the view hierarchy for as long as we're around.
    synchronizedScrollView = scrollview;
    
    // get the content view of the
    synchronizedContentView=[synchronizedScrollView contentView];
    
    // Make sure the watched view is sending bounds changed
    // notifications (which is probably does anyway, but calling
    // this again won't hurt).
    [synchronizedContentView setPostsBoundsChangedNotifications:YES];
    
    // a register for those notifications on the synchronized content view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchronizedViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:synchronizedContentView];
}



- (void)synchronizedViewContentBoundsDidChange:(NSNotification *)notification
{
    // get the changed content view from the notification
    NSClipView *changedContentView=[notification object];
    //NSScrollView *changedScrollView = [changedContentView enclosingScrollView];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;;
    
    // get our current origin
    NSPoint curOffset = [[self contentView] bounds].origin;
    NSPoint newOffset = curOffset;
    
    // scrolling is synchronized in the vertical plane
    // so only modify the y component of the offset
    if ([verticalSynchedScrollViews containsObject:changedContentView]) {
        newOffset.y = changedBoundsOrigin.y;
    }
    if ([horizontalSynchedScrollViews containsObject:changedContentView]) {
        newOffset.x = changedBoundsOrigin.x;
    }
    
    // if our synced position is different from our current
    // position, reposition our content view
    if (!NSEqualPoints(curOffset, changedBoundsOrigin))
    {
        // note that a scroll view watching this one will
        // get notified here
        [[self contentView] scrollToPoint:newOffset];

        // we have to tell the NSScrollView to update its
        // scrollers
        [self reflectScrolledClipView:[self contentView]];
    }
}


- (void)stopSynchronizing
{
    if (synchronizedScrollView != nil) {
        NSView* synchronizedContentView = [synchronizedScrollView contentView];
        
        // remove any existing notification registration
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSViewBoundsDidChangeNotification
                                                      object:synchronizedContentView];
        
        // set synchronizedScrollView to nil
        synchronizedScrollView=nil;
    }
}

@end
