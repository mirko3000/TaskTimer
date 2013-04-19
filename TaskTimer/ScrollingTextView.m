//
//  ScrollingTextView.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 15.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//


#import "ScrollingTextView.h"
#import "AppDelegate.h"

@implementation ScrollingTextView

@synthesize text;
@synthesize speed;

NSDictionary *attrs;
AppDelegate *delegate;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        staticText = [[NSMutableString alloc]init];
        scrollingText = [[NSMutableString alloc]init];

        // Initialize text position
        point = NSZeroPoint;
        point.y = 3;
        
        // Set text attributes (font)
        NSFont *font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
        //NSFont *font = [NSFont systemFontOfSize:14];
        //NSFont* font= [NSFont fontWithName:@"Helvetica" size:12.0];
        
        attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
        
        scroller = NULL;
        
    }
    return self;
}


- (void) setScrollingText:(NSString *)newText {
    [scrollingText setString:newText];
    stringWidth = [newText sizeWithAttributes:attrs].width;
}



- (void) setStaticText:(NSString *)newText {
    [staticText setString:newText];
    if (scroller == NULL) {
        text = staticText;
    }
}

- (void) setDel:(AppDelegate *) del {
    delegate = del;
}


// Force refresh
- (void) updateText {
    [self setNeedsDisplay:YES];
}


- (void) setSpeed:(NSTimeInterval)newSpeed {
    if (newSpeed != speed) {
        speed = newSpeed;
        [scroller invalidate];
        scroller = nil;
    }
}


- (void) startAnimation {
    if (scroller == NULL) {
        NSSize size = self.frame.size;
        point.x = size.width;
        text = scrollingText;
    
        if (speed > 0 && scrollingText != nil) {
            scroller = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        }
    }
}


- (void) moveText:(NSTimer *)timer {
    point.x = point.x - 0.08f;
    [self setNeedsDisplay:YES];
    
    // Stop timer if string reaches outer limit
    if (point.x < -(stringWidth+10)) {
        [scroller invalidate];
        scroller = NULL;
        text = staticText;
        point.x = 0;
    }
}


- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.

    // Set background color
    //[[NSColor redColor] set];
    //NSRectFill([self bounds]);
    
    [text drawAtPoint:point withAttributes:attrs];
}


-(BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}


-(void)mouseDown:(NSEvent *)event {
    [delegate showStatusBarPopover:self];
}


@end
