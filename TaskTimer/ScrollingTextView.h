//
//  ScrollingTextView.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 15.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScrollingTextView : NSView {
    NSTimer * scroller;
    NSPoint point;
    NSString * text;
    NSString * staticText;
    NSString * scrollingText;
    NSTimeInterval speed;
    CGFloat stringWidth;
}

- (void) setStaticText: (NSString*) text;
- (void) setScrollingText: (NSString*) text;
- (void) setSpeed: (NSTimeInterval) speed;
- (void) startAnimation;
- (void) updateText;

@property (nonatomic, copy) NSString * text;
@property (nonatomic, copy) NSString * staticText;
@property (nonatomic, copy) NSString * scrollingText;
@property (nonatomic) NSTimeInterval speed;

@end
