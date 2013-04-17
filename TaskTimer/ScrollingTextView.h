//
//  ScrollingTextView.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 15.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppDelegate;

@interface ScrollingTextView : NSView {
    NSTimer * scroller;
    NSPoint point;
    NSMutableString * text;
    NSMutableString * staticText;
    NSMutableString * scrollingText;
    NSTimeInterval speed;
    CGFloat stringWidth;
}

- (void) setStaticText: (NSString*) text;
- (void) setScrollingText: (NSString*) text;
- (void) setSpeed: (NSTimeInterval) speed;
- (void) setDel: (AppDelegate*) delegate;
- (void) startAnimation;
- (void) updateText;

@property (nonatomic, copy) NSMutableString * text;
@property (nonatomic) NSTimeInterval speed;

@end
