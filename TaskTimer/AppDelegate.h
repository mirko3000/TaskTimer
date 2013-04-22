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
@class DataManager;

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
    IBOutlet NSTextField *detailsCommentField;
    
    // Inactivity sheet
    IBOutlet NSPanel *inactivityWindow;
    IBOutlet NSTextField *awayTimeValueLabel;
    IBOutlet NSComboBox *inactivityTaskCombo;
    IBOutlet NSMatrix *inactivityRadioGroup;
    IBOutlet NSButton *inactivityCheckbox;
    
    IBOutlet NSToolbarItem *silentButton;
    
    // Data Management
    IBOutlet DataManager *dm;

}

- (IBAction)startTiming:(id)sender;
- (IBAction)stopTiming:(id)sender;

- (IBAction)showInfoPopup:(id)sender;
- (IBAction)showInactivityPopup:(id)sender;
- (IBAction)closeInactivityPopup:(id)sender;

// Actions in the inactivity popup
- (IBAction) radioButtonSelected:(id)sender;

- (void) showStatusBarPopover:(id)sender;

// Show timesheet window
- (IBAction) showTimeSheet:(id)sender;

// Persistence action
- (IBAction)toggleSilentMode:(id)sender;

// Persistence action
- (IBAction)saveAction:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPopover *popover;

@end
