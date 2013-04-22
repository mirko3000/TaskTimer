//
//  AppDelegate.m
//  TaskTimer
//
//  Created by Mirko Bleyh on 06.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import "AppDelegate.h"
#import "TimeSheetController.h"
#import "ScrollingTextView.h"
#import "FBScrollingTextView.h"
#import "DataManager.h"

@implementation AppDelegate

//@synthesize window;
@synthesize window = _window;
@synthesize popover;

// Variables for the timer
NSInteger currentFrame;
NSTimer* animTimer;
NSDate* startDate;
NSManagedObject *currentTimingTask;

// Variable to track idle time
NSDate* lastMouseMovement;
NSDate* lastMouseMovementPopup;

// Data Manager
DataManager *dm;

// Silent mode flag
bool silent = false;


- (id)init {
    self = [super init];
    if (self) {
        // Do initialization stuff
    }
    return self;
}


-(void)awakeFromNib{
//    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
//    [statusItem setMenu:statusMenu];
//    [statusItem setTitle:@"--:--:--"];
//    [statusItem setHighlightMode:YES];
//    [statusItem setTarget: self];
//    [statusItem setAction:@selector(openWin:)];

    // We need to use a Button here as the view of the menu item to make it clickable for the popup!
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    //Scrolling Text View
	//scrollingView = [[FBScrollingTextView alloc] initWithFrame:CGRectMake(0, 0, 80, 22)];
	//scrollingView.font = [NSFont fontWithName:@"Lucida Sans" size:13];
	//[scrollingView setString:@"Some long long long text"];
    
    
    scrollingView = [[ScrollingTextView alloc] initWithFrame:NSMakeRect(0, 0, 58, 40)];
    [scrollingView setStaticText:@"--:--:--"];
    [scrollingView setScrollingText:@"<missing task>"];
    [scrollingView setSpeed:0.015];
    [scrollingView setDel:self];
    [scrollingView updateText];
    
    //[statusView setAc]
    
//    statusItemButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 83, 22)];
//    statusItemButton.title = @"--:--:--";
//    statusItemButton.bordered = NO;
//    [statusItemButton setAction:@selector(clickStatusBar:)];
    //statusItem.view = statusItemButton;
    statusItem.view = scrollingView;
    
    [taskSegControl setTarget:self];
    [taskSegControl setAction:@selector(taskSegControlClicked:)];
    
    [timeSegControl setTarget:self];
    [timeSegControl setAction:@selector(timeSegControlClicked:)];
    
    // Configure doubeclick-action
    [timingsTableView setDoubleAction:@selector(doubleClick:)];
    
    // Set the default sort columns for the tables
    NSSortDescriptor* taskSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [tasksTableView setSortDescriptors:[NSArray arrayWithObject:taskSortDescriptor]];
    
    NSSortDescriptor* timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start" ascending:YES];
    [timingsTableView setSortDescriptors:[NSArray arrayWithObject:timeSortDescriptor]];
    
    // Set color of the checkbox
    NSMutableDictionary *attrs = [[NSMutableDictionary alloc]init];
    NSFont *font = [NSFont systemFontOfSize:11];
    [attrs setObject:font forKey:NSFontAttributeName];
    [attrs setObject:[NSColor
                      whiteColor]forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString:@"Continue timing with this task" attributes:attrs];
    [inactivityCheckbox setAttributedTitle:attrStr];
    
    // Set color of the radio buttons
    NSArray *cells = [inactivityRadioGroup cells];
    for (NSButtonCell *cell in cells) {
        
        NSColor *txtColor = [NSColor whiteColor];
        NSFont *txtFont = [NSFont systemFontOfSize:11];
        NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 txtFont, NSFontAttributeName, txtColor, NSForegroundColorAttributeName, nil];
        NSAttributedString *attrStr = [[NSAttributedString alloc]
                                        initWithString:[cell title] attributes:txtDict];
        [cell setAttributedTitle:attrStr];
    }

    [inactivityTaskCombo setEnabled:FALSE];
    [inactivityCheckbox setEnabled:FALSE];
    
    [startButton setEnabled:TRUE];
    [stopButton setEnabled:FALSE];
    [popupStopButton setEnabled:FALSE];
    
    // Key Handler
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
                                           handler:^(NSEvent *event){

                                               //NSString *chars = [[event characters] lowercaseString];
                                               //unichar character = [chars characterAtIndex:0];

                                               if (lastMouseMovement == NULL) {
                                                   lastMouseMovement = [[NSDate alloc] init];
                                               }
                                               else {
                                                   NSTimeInterval interval = -[lastMouseMovement timeIntervalSinceNow];
                                                   if (interval > 120) {
                                                       NSLog(@"Awake from inaktive: %f", interval);
                                                       [self showInactivityPopup:self];
                                                   }
                                                   if (interval > 1) {
                                                       lastMouseMovement = [[NSDate alloc] init];
                                                   }
                                               }
                                           }];
    
    
    // Mouse Handler
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask
                                           handler:^(NSEvent *event){
                                    
                                               if (lastMouseMovement == NULL) {
                                                   lastMouseMovement = [[NSDate alloc] init];
                                               }
                                               else {
                                                   NSTimeInterval interval = -[lastMouseMovement timeIntervalSinceNow];
                                                   if (interval > 10) {
                                                       NSLog(@"Awake from inaktive: %f", interval);
                                                       [self showInactivityPopup:self];
                                                   }
                                                   if (interval > 1) {
                                                       lastMouseMovement = [[NSDate alloc] init];
                                                   }
                                               }
                                           }];
    
}


// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[dm managedObjectContext] undoManager];
}



// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[dm managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[dm managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}



- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Stop running timing
    if (currentTimingTask != NULL) {
        [self stopTiming:self];
    }
    
    
    // Save changes in the application's managed object context before the application terminates.
    
    if (![dm managedObjectContext]) {
        return NSTerminateNow;
    }
    
    if (![[dm managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[dm managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[dm managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    
    
    [NSEvent removeMonitor:self];
    
    return NSTerminateNow;
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    

}



// Make that the App reappears after beeing closed
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if ( flag ) {
        [self.window orderFront:self];
    }
    else {
        [self.window makeKeyAndOrderFront:self];
    }
    
    return YES;
}



-(void)showStatusBarPopover:(id)sender{
    [[self popover] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}



// Dispath the add/remove buttons from the task table
- (IBAction)taskSegControlClicked:(id)sender
{
    int clickedSegment = (int)[sender selectedSegment];
    
    //int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if (clickedSegment == 0) {
        [self addNewTaskItem:self];
    }
    else if (clickedSegment == 1) {
        [self removeTaskItem:self];
    }
}


// Dispath the add/remove buttons from the time table
- (IBAction)timeSegControlClicked:(id)sender
{
    int clickedSegment = (int)[sender selectedSegment];
    
    //int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if (clickedSegment == 0) {
        [self addNewTimeItem:self];
    }
    else if (clickedSegment == 1) {
        [self removeTimeItem:self];
    }
}



- (IBAction)addNewTaskItem:(id)sender {
    NSManagedObject *newTask = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Task"
                                    inManagedObjectContext:[dm managedObjectContext]];
    
    //[newTask setValue:@"Test" forKey:@"finished"];
    [newTask setValue:@"New Task" forKey:@"name"];
    [newTask setValue:[[NSNumber alloc] initWithDouble:0.0] forKey:@"totalTime"];
    NSLog(@"Adding Task: %@", [newTask valueForKey:@"name"]);
    
    [taskItemsArrayController addObject:newTask];
}



- (IBAction)removeTaskItem:(id)sender {
    
    NSArray *selObj = [taskItemsArrayController selectedObjects];    
    
    if ([selObj count] > 0) {
        
        NSManagedObject *task = [selObj objectAtIndex:0];
        
        // First remove all timings to this task
        NSArray *timings = [task valueForKey:@"timings"];
        for (id time in timings) {
            [timeItemsArrayController removeObject:time];
        }
        
        // Now remove task
        [taskItemsArrayController removeObject:[selObj objectAtIndex:0]];
    }
}



- (IBAction)addNewTimeItem:(id)sender {
    if ([[timeItemsArrayController selectedObjects] count] > 0) {
    
    NSManagedObject *newTime = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Time"
                                inManagedObjectContext:[dm managedObjectContext]];
    
    NSManagedObject *selTime = [[timeItemsArrayController selectedObjects] objectAtIndex:0];
    
    [newTime setValue:[selTime valueForKey:@"task"] forKey:@"task"];
    [newTime setValue:[[NSDate alloc] init] forKey:@"start"];
    [newTime setValue:[[NSDate alloc] init] forKey:@"end"];
    [newTime setValue:0 forKey:@"duration"];
    [newTime setValue:@"" forKey:@"comment"];
        
    [timeItemsArrayController addObject:newTime];
    
    [NSApp beginSheet:detailsSheet
       modalForWindow:(NSWindow *)_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
    }
}



- (IBAction)removeTimeItem:(id)sender {
    NSArray *selObj = [timeItemsArrayController selectedObjects];
    
    if ([selObj count] > 0) {
        
        // Recalculate total time for task
        NSManagedObject *timing = [selObj objectAtIndex:0];
        NSManagedObject *task = [timing valueForKey:@"task"];
        
        NSNumber *duration = [timing valueForKey:@"duration"];
        NSLog(@"Duration %@:", duration);
        
        [timing setValue:[[NSNumber alloc] initWithDouble:(-[duration longValue])] forKey:@"duration"];
        
        [self recalculateTotalTime:task :timing];
        
        [timeItemsArrayController removeObject:[selObj objectAtIndex:0]];
    }
}



- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}



- (IBAction)startTiming:(id)sender
{
    
    if ([[taskItemsArrayController selectedObjects] count] == 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No Task selected" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"A Task has to be selected to start timing." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return;
    }
    
    currentFrame = 0;
    animTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    startDate = [[NSDate alloc] init];
    
    currentTimingTask = [[taskItemsArrayController selectedObjects] objectAtIndex:0];
    
    // Update popover and show it
    [popupStatusLabel setStringValue:[currentTimingTask valueForKey:@"name"]];
    
    //Show the popup
    //[[self popover] showRelativeToRect:[statusItemButton bounds] ofView:statusItemButton preferredEdge:NSMaxYEdge];
    [[self popover] showRelativeToRect:[scrollingView bounds] ofView:scrollingView preferredEdge:NSMaxYEdge];
    
    [startButton setEnabled:FALSE];
    [stopButton setEnabled:TRUE];
    [popupStopButton setEnabled:TRUE];

    [scrollingView setScrollingText:[currentTimingTask valueForKey:@"name"]];
    [scrollingView startAnimation];
}


- (IBAction)stopTiming:(id)sender
{
    if (currentTimingTask == NULL) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"No Timing active" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"A Timing has to be aactive to stop timing." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return;
    }
    
    [animTimer invalidate];
    [scrollingView setStaticText:@"--:--:--"];
    [scrollingView updateText];
    
    NSManagedObject *newTiming = [NSEntityDescription
                                insertNewObjectForEntityForName:@"Time"
                                inManagedObjectContext:[dm managedObjectContext]];

    [newTiming setValue:startDate forKey:@"start"];
    [newTiming setValue:[[NSDate alloc] init] forKey:@"end"];
  
    NSTimeInterval interval = -[startDate timeIntervalSinceNow];
    [newTiming setValue:[[NSNumber alloc] initWithDouble:interval] forKey:@"duration"];
    
    [newTiming setValue:currentTimingTask forKey:@"task"];
    
    [self recalculateTotalTime:currentTimingTask:newTiming];
    
    //NSLog(@"Added Timing: %@", [newTiming valueForKey:@"duration"]);
    
    [timeItemsArrayController addObject:newTiming];
    
    currentTimingTask = NULL;
    
    [popupStatusLabel setStringValue:@"---"];
    
    //Show the popup
    [[self popover] showRelativeToRect:[scrollingView bounds] ofView:scrollingView preferredEdge:NSMaxYEdge];
    
    // Save data
    [self saveAction:self];
    
    [startButton setEnabled:TRUE];
    [stopButton setEnabled:FALSE];
    [popupStopButton setEnabled:FALSE];
    
    [self doubleClick:self];
}


- (void)recalculateTotalTime:(NSManagedObject*)forTask :(NSManagedObject*)withTiming {    
    // Get current total time of the Task
    NSTimeInterval interval = [[forTask valueForKey:@"totalTime"] doubleValue];
    NSTimeInterval newTime = [[withTiming valueForKey:@"duration"] doubleValue];

    NSLog(@"Old Total Time: %@", [forTask valueForKey:@"totalTime"]);
    NSLog(@"New Total Time: %@", [[NSNumber alloc] initWithDouble:(interval + newTime)]);

    
    [forTask setValue:[[NSNumber alloc] initWithDouble:(interval + newTime)] forKey:@"totalTime"];
}


- (void)updateTimer:(NSTimer*)timer
{
    NSTimeInterval interval = -[startDate timeIntervalSinceNow];
    int seconds = ((int) interval) % 60;
    int minutes = ((int) (interval - seconds) / 60) % 60;
    int hours = ((int) interval - seconds - 60 * minutes) / 3600;
    
    if (minutes % 15 == 0 && seconds == 0 && !silent) {
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Task Timer Notification";
        notification.informativeText = [NSString stringWithFormat:@"You are currently timing %@", [currentTimingTask valueForKey:@"name"]];
//        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    
    if (minutes % 1 == 0 && seconds == 0 && !silent) {
        [scrollingView startAnimation];
    }
    
    [scrollingView setStaticText:[NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours,
                                 minutes, seconds]];
    [scrollingView updateText];
}



- (void) showInactivityPopup:(id)object {
    
    if(! [inactivityWindow isVisible] && !silent) {
        
        lastMouseMovementPopup = [lastMouseMovement copy];
        
        // Calculate away time
        NSTimeInterval interval = -[lastMouseMovementPopup timeIntervalSinceNow];
        int seconds = ((int) interval) % 60;
        int minutes = ((int) (interval - seconds) / 60) % 60;
        int hours = ((int) interval - seconds - 60 * minutes) / 3600;
        
        if (hours > 0) {
            [awayTimeValueLabel setStringValue:[NSString stringWithFormat:@"%.2d hours, %.2d minutes, %.2d minutes", hours, minutes, seconds]];
        }
        else if (minutes > 0) {
            [awayTimeValueLabel setStringValue:[NSString stringWithFormat:@"%.2d minutes, %.2d seconds", minutes, seconds]];
        }
        else {
             [awayTimeValueLabel setStringValue:[NSString stringWithFormat:@"%.2d seconds", seconds]];
        }
        
        NSArray *a = [taskItemsArrayController arrangedObjects];
        
        if (currentTimingTask != NULL) {
            [inactivityTaskCombo selectItemAtIndex:[a indexOfObject:currentTimingTask]];
            [inactivityRadioGroup selectCellWithTag:2];
        }

        [self radioButtonSelected:inactivityRadioGroup];
        [inactivityWindow makeKeyAndOrderFront:object];
        [inactivityWindow setWorksWhenModal:TRUE];
    }
}


- (void) closeInactivityPopup:(id)object {
    
    // Check if we have a running timing and not selected "do nothing"
    if (currentTimingTask == nil) {
        
        if  ([[inactivityRadioGroup selectedCell] tag] == 2)  {
            
            NSManagedObject *selValue = [[taskItemsArrayController arrangedObjects] objectAtIndex:[inactivityTaskCombo indexOfSelectedItem]];
            
            // Check if we should start timing
            if ([inactivityCheckbox state] == NSOnState) {
                
                [taskItemsArrayController setSelectionIndex:[inactivityTaskCombo indexOfSelectedItem]];
                [self startTiming:self];
                
                startDate = [lastMouseMovementPopup copy];
                
            }
            else {
            
                NSManagedObject *newTiming = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Time"
                                      inManagedObjectContext:[dm managedObjectContext]];
        
                [newTiming setValue:lastMouseMovementPopup forKey:@"start"];
                [newTiming setValue:[[NSDate alloc] init] forKey:@"end"];
        
                NSTimeInterval interval = -[lastMouseMovementPopup timeIntervalSinceNow];
                [newTiming setValue:[[NSNumber alloc] initWithDouble:interval] forKey:@"duration"];
        
                [newTiming setValue:selValue forKey:@"task"];
        
                [self recalculateTotalTime:selValue:newTiming];

                [timeItemsArrayController addObject:newTiming];
                
                
                // Open details panel
                [self doubleClick:self];
            
            }
        }
    }
    // Else we have a running timing
    else {
        // If we have a running timing, and a different task was selected for the inactivity
        // time, we need to do:
        // - Store the running timing from the start date to the inactivity start date
        // - Store a new task from the inactivity start date till now
        // - Set the start date of the running timing to now
        // If the same task as the running timing was chosen, then we can just continue
        // If the option "do nothing" was chosen, then we need to add a timing from the start
        // until the inactivity beginn, and start a new timing from now on
        if ([[inactivityRadioGroup selectedCell] tag] == 2) {
            // Selected "start timing..."
            
            NSManagedObject *selValue = [[taskItemsArrayController arrangedObjects] objectAtIndex:[inactivityTaskCombo indexOfSelectedItem]];
            
            if ([currentTimingTask isEqualTo:selValue]) {
                // continue
            }
            else {
                // Store the running timing
                NSManagedObject *runningTiming = [NSEntityDescription
                                              insertNewObjectForEntityForName:@"Time"
                                              inManagedObjectContext:[dm managedObjectContext]];
                
                [runningTiming setValue:startDate forKey:@"start"];
                [runningTiming setValue:lastMouseMovementPopup forKey:@"end"];
                
                NSTimeInterval interval = [lastMouseMovementPopup timeIntervalSinceDate:startDate];
                [runningTiming setValue:[[NSNumber alloc] initWithDouble:interval] forKey:@"duration"];
                
                [runningTiming setValue:currentTimingTask forKey:@"task"];
                
                [self recalculateTotalTime:currentTimingTask:runningTiming];
                
                [timeItemsArrayController addObject:runningTiming];
                
                
                // Store inactivity task
                NSManagedObject *inactivityTiming = [NSEntityDescription
                                              insertNewObjectForEntityForName:@"Time"
                                                     inManagedObjectContext:[dm managedObjectContext]];
                
                [inactivityTiming setValue:lastMouseMovementPopup forKey:@"start"];
                [inactivityTiming setValue:[[NSDate alloc] init] forKey:@"end"];
                
                NSTimeInterval inactivityInterval = -[lastMouseMovementPopup timeIntervalSinceNow];
                [inactivityTiming setValue:[[NSNumber alloc] initWithDouble:inactivityInterval] forKey:@"duration"];
                
                [inactivityTiming setValue:selValue forKey:@"task"];
                
                [self recalculateTotalTime:selValue:inactivityTiming];
                
                [timeItemsArrayController addObject:inactivityTiming];
                
                // Start (virtually) new timing
                startDate = [[NSDate alloc] init];
                
                if ([inactivityCheckbox state] == NSOnState) {
                    // Continue with the inactivity task
                    currentTimingTask = selValue;
                }
                else {
                    // Continue with the running task
                }
                
                // Update popover and show it
                [popupStatusLabel setStringValue:[currentTimingTask valueForKey:@"name"]];
                
                //Show the popup
                [[self popover] showRelativeToRect:[scrollingView bounds] ofView:scrollingView preferredEdge:NSMaxYEdge];
             
                // Show details panel
                [self doubleClick:self];
                
            }
        }
        
        else {
            // Selected "do nothing"
            
            // Add a new timing until the inactivity start, and start timing from
            // now on
            // Store inactivity task
            NSManagedObject *inactivityTiming = [NSEntityDescription
                                                 insertNewObjectForEntityForName:@"Time"
                                                 inManagedObjectContext:[dm managedObjectContext]];
            
            [inactivityTiming setValue:startDate forKey:@"start"];
            [inactivityTiming setValue:lastMouseMovementPopup forKey:@"end"];
            
            NSTimeInterval inactivityInterval = [lastMouseMovementPopup timeIntervalSinceDate:startDate];
            [inactivityTiming setValue:[[NSNumber alloc] initWithDouble:inactivityInterval] forKey:@"duration"];
            
            [inactivityTiming setValue:currentTimingTask forKey:@"task"];
            
            [self recalculateTotalTime:currentTimingTask:inactivityTiming];
            
            [timeItemsArrayController addObject:inactivityTiming];
            
            // Start timing from now on with the same task
            startDate = [[NSDate alloc] init];
            
            // Update popover and show it
            [popupStatusLabel setStringValue:[currentTimingTask valueForKey:@"name"]];
            
            //Show the popup
            [[self popover] showRelativeToRect:[scrollingView bounds] ofView:scrollingView preferredEdge:NSMaxYEdge];
            
            [self doubleClick:self];
        }
    }
    
    // Save data
    [self saveAction:self];
    
    // Close the window
    [NSApp endSheet:inactivityWindow];
    [inactivityWindow orderOut:object];
}


- (IBAction) radioButtonSelected:(id)sender {
    
    switch ([[sender selectedCell] tag]) {
        case 1:
            [inactivityTaskCombo setEnabled:FALSE];
            [inactivityCheckbox setEnabled:FALSE];
            break;
        case 2:
            [inactivityTaskCombo setEnabled:TRUE];
            [inactivityCheckbox setEnabled:TRUE];
            break;
    }
}



- (void)doubleClick:(id)object {
    [NSApp beginSheet:detailsSheet
       modalForWindow:(NSWindow *)_window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
    
    [detailsSheet makeFirstResponder:detailsCommentField];
    
}


-(IBAction)endTheSheet:(id)sender {
    [NSApp endSheet:detailsSheet];
    [detailsSheet orderOut:sender];
    
    // Save data
    [self saveAction:self];
}



-(IBAction)showTimeSheet:(id)sender {
    if (!timeSheetController) {
        timeSheetController = [[TimeSheetController alloc] initWithWindowNibName:@"TimesheetWindow"];
    }
    
    [timeSheetController setData:[timeItemsArrayController arrangedObjects]];
    [timeSheetController showWindow:self];
}



- (IBAction)toggleSilentMode:(id)sender {
    
    if (silent == FALSE) {
        silent = TRUE;
        //[silentButton setLabel:@"Silent"];
        [silentButton setImage:[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"notification.png"]]];
    }
    else {
        silent = FALSE;
        //[silentButton setLabel:@"Normal"];
        [silentButton setImage:[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForImageResource:@"notification_disabled.png"]]];

    }
}



@end
