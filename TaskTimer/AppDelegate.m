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

@implementation AppDelegate

//@synthesize window;
@synthesize window = _window;
@synthesize popover;
@synthesize taskEntryPopup;

// Variables for the timer
NSInteger currentFrame;
NSTimer* animTimer;
NSDate* startDate;
NSManagedObject *currentTimingTask;

// Variable to track idle time
NSDate* lastMouseMovement;
NSDate* lastMouseMovementPopup;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;


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
    
    
    scrollingView = [[ScrollingTextView alloc] initWithFrame:NSMakeRect(0, 0, 60, 40)];
    [scrollingView setStaticText:@"00:00:00"];
    [scrollingView setScrollingText:@"Fachkonzept Stufe 2"];
    [scrollingView setSpeed:0.015];
    
    //[statusView setAc]
    
    statusItemButton = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 83, 22)];
    statusItemButton.title = @"--:--:--";
    statusItemButton.bordered = NO;
    [statusItemButton setAction:@selector(clickStatusBar:)];
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
                                                   if (interval > 120) {
                                                       NSLog(@"Awake from inaktive: %f", interval);
                                                       [self showInactivityPopup:self];
                                                   }
                                                   if (interval > 1) {
                                                       lastMouseMovement = [[NSDate alloc] init];
                                                   }
                                               }
                                               
                                           }];
    
}


// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "de.mbsoft.TestCoreData" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"de.mbsoft.TaskTimer"];
}



// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TaskTimer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}



// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"TaskTimer.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}



// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}



// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}



// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}



- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
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


-(void)clickStatusBar:(id)sender{
    [[self popover] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}



- (IBAction)taskSegControlClicked:(id)sender
{
    int clickedSegment = (int)[sender selectedSegment];
    
    //int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if (clickedSegment == 0) {
        [self addNewTaskItem:self];
    }
    else {
        [self removeTaskItem:self];
    }
}


- (IBAction)timeSegControlClicked:(id)sender
{
    int clickedSegment = (int)[sender selectedSegment];
    
    //int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if (clickedSegment == 0) {
        [self addNewTimeItem:self];
    }
    else {
        [self removeTimeItem:self];
    }
}



- (IBAction)addNewTaskItem:(id)sender {
    NSManagedObject *newTask = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Task"
                                    inManagedObjectContext:_managedObjectContext];
    
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
                                inManagedObjectContext:_managedObjectContext];
    
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
    [scrollingView startAnimation];
    
    
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
                                inManagedObjectContext:_managedObjectContext];

    [newTiming setValue:startDate forKey:@"start"];
    [newTiming setValue:[[NSDate alloc] init] forKey:@"end"];
  
    NSTimeInterval interval = -[startDate timeIntervalSinceNow];
    [newTiming setValue:[[NSNumber alloc] initWithDouble:interval] forKey:@"duration"];
    
    [newTiming setValue:currentTimingTask forKey:@"task"];
    
    [self recalculateTotalTime:currentTimingTask:newTiming];
    
    
    NSLog(@"Added Timing: %@", [newTiming valueForKey:@"duration"]);
    
    [timeItemsArrayController addObject:newTiming];
    
    currentTimingTask = NULL;
    
    [popupStatusLabel setStringValue:@"---"];
    
    //Show the popup
    [[self popover] showRelativeToRect:[scrollingView bounds] ofView:scrollingView preferredEdge:NSMaxYEdge];
    
    //Show time entry popup
    //[taskEntryPopup makeKeyAndOrderFront:nil];
    
    
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
    
    if (minutes % 15 == 0 && seconds == 0) {
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Task Timer Notification";
        notification.informativeText = [NSString stringWithFormat:@"You are currently timing %@", [currentTimingTask valueForKey:@"name"]];
//        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

    }
    [scrollingView setStaticText:[NSString stringWithFormat:@"%.2d:%.2d:%.2d", hours,
                                 minutes, seconds]];
    [scrollingView updateText];
}



- (void) showInactivityPopup:(id)object {
    
    if(! [inactivityWindow isVisible] ) {
        
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
                                      inManagedObjectContext:_managedObjectContext];
        
                [newTiming setValue:lastMouseMovementPopup forKey:@"start"];
                [newTiming setValue:[[NSDate alloc] init] forKey:@"end"];
        
                NSTimeInterval interval = -[lastMouseMovementPopup timeIntervalSinceNow];
                [newTiming setValue:[[NSNumber alloc] initWithDouble:interval] forKey:@"duration"];
        
                [newTiming setValue:selValue forKey:@"task"];
        
                [self recalculateTotalTime:selValue:newTiming];

                [timeItemsArrayController addObject:newTiming];
            
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
                                              inManagedObjectContext:_managedObjectContext];
                
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
                                              inManagedObjectContext:_managedObjectContext];
                
                [inactivityTiming setValue:lastMouseMovementPopup forKey:@"start"];
                [inactivityTiming setValue:[[NSDate alloc] init] forKey:@"end"];
                
                NSTimeInterval inactivityInterval = -[lastMouseMovementPopup timeIntervalSinceNow];
                [inactivityTiming setValue:[[NSNumber alloc] initWithDouble:inactivityInterval] forKey:@"duration"];
                
                [inactivityTiming setValue:selValue forKey:@"task"];
                
                [self recalculateTotalTime:selValue:inactivityTiming];
                
                [timeItemsArrayController addObject:inactivityTiming];
                
                // Start (virtually) new timing
                startDate = [[NSDate alloc] init];
                currentTimingTask = selValue;
                
                // Update popover and show it
                [popupStatusLabel setStringValue:[currentTimingTask valueForKey:@"name"]];
                
                //Show the popup
                [[self popover] showRelativeToRect:[statusItemButton bounds] ofView:statusItemButton preferredEdge:NSMaxYEdge];
                
            }
        }
        
        else {
            // Selected "do nothing"
            
            // Add a new timing until the inactivity start, and start timing from
            // now on
            // Store inactivity task
            NSManagedObject *inactivityTiming = [NSEntityDescription
                                                 insertNewObjectForEntityForName:@"Time"
                                                 inManagedObjectContext:_managedObjectContext];
            
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
            [[self popover] showRelativeToRect:[statusItemButton bounds] ofView:statusItemButton preferredEdge:NSMaxYEdge];
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
    
    [timeSheetController showWindow:self];
}



@end