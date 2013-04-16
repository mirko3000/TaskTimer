//
//  ScrollingTextView.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 15.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//


#import "ScrollingTextView.h"

@implementation ScrollingTextView

@synthesize text;
@synthesize staticText;
@synthesize scrollingText;
@synthesize speed;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.

    }
    return self;
}


- (void) setScrollingText:(NSString *)newText {
    scrollingText = [newText copy];
    point = NSZeroPoint;
    
    stringWidth = [newText sizeWithAttributes:nil].width;
}



- (void) setStaticText:(NSString *)newText {
    staticText = [newText copy];
    //text = staticText;
    //[self setNeedsDisplay:YES];
}


- (void) updateText {
    [self setNeedsDisplay:YES];
    text = staticText;
    NSLog(@"Testsst");
}


- (void) setSpeed:(NSTimeInterval)newSpeed {
    NSLog(@"Setting speed");
    if (newSpeed != speed) {
        speed = newSpeed;
        
        [scroller invalidate];
        scroller = nil;
    }
}

- (void) startAnimation {
    NSSize size = self.frame.size;
    point.x = size.width;
    text = scrollingText;
    
    if (speed > 0 && scrollingText != nil) {
        scroller = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
    }
    
}


- (void) moveText:(NSTimer *)timer {
    point.x = point.x - 1.0f;
    [self setNeedsDisplay:YES];
    
    // Stop timer if string reaches outer limit
    if (point.x < -(stringWidth)) {
        [scroller invalidate];
        text = staticText;
        point.x = 0;
    }
}


- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    
    //if (point.x + stringWidth < 0) {
    //    point.x += dirtyRect.size.width;
    //    NSLog(@"Fehler?");
    //}
    NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    
    [text drawAtPoint:point withAttributes:attrs];
    
    //if (point.x < 0) {
    //    NSPoint otherPoint = point;
    //    otherPoint.x += dirtyRect.size.width;
    //    [text drawAtPoint:otherPoint withAttributes:nil];
    //}
}

@end
