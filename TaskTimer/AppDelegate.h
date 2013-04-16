//
//  AppDelegate.h
//  TaskTimer
//
//  Created by Mirko Bleyh on 06.04.13.
//  Copyright (c) 2013 Mirko Bleyh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TimeSheetController;
@class ScrollingTextView;
@class FBScrollingTextView;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    TimeSheetController *timeSheetController;
    
    // TaskBar-Items
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSButton *statusItemButton;
    ScrollingTextView *scrollingView;
    
    // Table Array Controller
    IBOutlet NSArrayController *taskItemsArrayController;
    IBOutlet NSArrayController *timeItemsArrayController;
    
    // Task Chooser
    //IBOutlet NSComboBox *taskChooser;
    
    // Toolbar Buttons
    IBOutlet NSToolbarItem *startButton;
    IBOutlet NSToolbarItem *stopButton;
    
    // Tables
    IBOutlet NSTableView *tasksTableView;
    IBOutlet NSTableView *timingsTableView;
    
    // TableButton-Bars
    IBOutlet NSSegmentedControl *taskSegControl;
    IBOutlet NSSegmentedControl *timeSegControl;
    
    // Popup definition
    IBOutlet NSView *popupView;
    IBOutlet NSTextField *popupStatusLabel;
    IBOutlet NSButton *popupStopButton;
    
    // Details sheet
    IBOutlet NSPanel *detailsSheet;
    
    // Inactivity sheet
    IBOutlet NSPanel *inactivityWindow;
    IBOutlet NSTextField *awayTimeValueLabel;
    IBOutlet NSComboBox *inactivityTaskCombo;
    IBOutlet NSMatrix *inactivityRadioGroup;
    IBOutlet NSButton *inactivityCheckbox;

}


- (IBAction)addNewTaskItem:(id)sender;
- (IBAction)removeTaskItem:(id)sender;

- (IBAction)addNewTimeItem:(id)sender;
- (IBAction)removeTimeItem:(id)sender;

- (IBAction)startTiming:(id)sender;
- (IBAction)stopTiming:(id)sender;

- (IBAction)showInfoPopup:(id)sender;
- (IBAction)showInactivityPopup:(id)sender;
- (IBAction)closeInactivityPopup:(id)sender;

// Actions in the inactivity popup
- (IBAction) radioButtonSelected:(id)sender;


// Show timesheet window
- (IBAction) showTimeSheet:(id)sender;


// Persistency objects
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// Scrolling text view
@property (retain) FBScrollingTextView *tView;

// Persistence action
- (IBAction)saveAction:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPopover *popover;
@property (assign) IBOutlet NSPanel *taskEntryPopup;


@end
