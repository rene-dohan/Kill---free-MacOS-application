//
//  AppDelegate.m
//  Kill
//
//  Created by Rene Dohan on 2/16/13.
//  Copyright (c) 2013 creative_studio. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "AppDelegate.h"

@implementation AppDelegate {
    id _mouseUpMonitor;
    id _keyMonitor;
    BOOL _monitoring;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    statusItem.image = [NSImage imageNamed:@"Remove Icon black.png"];
    [statusItem setHighlightMode:YES];
    [statusItem setTarget:self];
    [statusItem setAction:@selector(onStatusItemClick)];
    _about.delegate = self;
    _help.delegate = self;
    if ([self launchItemExists]) [_menuItemToggleLaunchOnLogin setState:NSOnState];
    
    if(![NSUserDefaults.standardUserDefaults boolForKey:@"first_start_key"]){
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"first_start_key"];
        [self showHelp];
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp stopModal];
}

- (IBAction)onToggleLogin:(NSMenuItem *)sender {
    sender.state = sender.state == NSOnState ? NSOffState : NSOnState;
    if (sender.state == NSOnState) [self enableLaunchAtLogin];
    else [self disableLaunchAtLogin];
}

- (IBAction)onAboutClick:(id)sender {
    NSTextField *field = (NSTextField*)[_about.contentView viewWithTag:3];
    [field setStringValue:NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"]];
     [[NSApplication sharedApplication] runModalForWindow:_about];
    [_about center];
}

- (IBAction)onQuitClick:(id)sender {
    [NSApplication.sharedApplication terminate:self];
}

- (IBAction)onCreativeSoftwareClick:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"http://creative-software.appspot.com"]];
}

- (IBAction)onNameClick:(id)sender {
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://www.facebook.com/dohan.rene"]];
}

- (void)onStatusItemClick {
    if (_about.isVisible) {
        [_about close];
        [NSApp stopModal];
    } else if (_help.isVisible) {
        [_help close];
        [NSApp stopModal];
    } else if (_monitoring) {
        [self cancelMonitor];
        [statusItem popUpStatusItemMenu:_menu];
    } else [self startMonitor];
}

- (void)startMonitor {
    _monitoring = YES;
    statusItem.image = [NSImage imageNamed:@"Remove Icon red.png"];
    _mouseUpMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseUpMask handler:^(NSEvent *event) {
        [self onMouseUp:event];
    }];
    _keyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *event) {
        [self onKeyDown:event];
    }];
}

- (void)onKeyDown:(NSEvent *)event {
    if (event.keyCode == kVK_Escape)[self cancelMonitor];
}

- (void)cancelMonitor {
    _monitoring = NO;
    statusItem.image = [NSImage imageNamed:@"Remove Icon black.png"];
    [NSEvent removeMonitor:_keyMonitor];
    [NSEvent removeMonitor:_mouseUpMonitor];
}

- (void)onMouseUp:(NSEvent *)event {
    int pid = [self findPID:event];
    for (NSRunningApplication *application in NSWorkspace.sharedWorkspace.runningApplications)
        if (application.processIdentifier == pid) [application forceTerminate];
    [self cancelMonitor];
}

- (int)findPID:(NSEvent *)event {
    CGWindowID windowID = (CGWindowID) [event windowNumber];
    CFArrayRef a = CFArrayCreate(NULL, (void *) &windowID, 1, NULL);
    NSArray *infos = (__bridge NSArray *) CGWindowListCreateDescriptionFromArray(a);
    CFRelease(a);
    if ([infos count] > 0) {
        NSDictionary *windowInfo = infos[0];
        return [[windowInfo objectForKey:(NSString *) kCGWindowOwnerPID] intValue];
    }
    return 0;
}

- (void)enableLaunchAtLogin {
    LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (!theLoginItemsRefs)return;
    CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath];
    LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRefs, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
    if (item) CFRelease(item);
    CFRelease(theLoginItemsRefs);
}

- (void)disableLaunchAtLogin {
    LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (!theLoginItemsRefs)return;
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in (__bridge NSArray *) loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef) item;
        if (LSSharedFileListItemResolve(itemRef, 0, &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *) thePath path] hasPrefix:NSBundle.mainBundle.bundlePath]) {
                LSSharedFileListItemRemove(theLoginItemsRefs, itemRef); // Deleting the item
            }
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);
    CFRelease(theLoginItemsRefs);
}

- (BOOL)launchItemExists {
    BOOL found = NO;
    UInt32 seedValue;
    CFURLRef thePath = NULL;
    CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL), &seedValue);
    for (id item in (__bridge NSArray *) loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef) item;
        if (LSSharedFileListItemResolve(itemRef, 0, &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *) thePath path] hasPrefix:NSBundle.mainBundle.bundlePath]) {
                found = YES;
                break;
            }
            if (thePath != NULL) CFRelease(thePath);
        }
    }
    if (loginItemsArray != NULL) CFRelease(loginItemsArray);

    return found;
}

- (void)showHelp {
    [[NSApplication sharedApplication] runModalForWindow:_help];
    [_help center];
}

- (IBAction)onHelpClick:(id)sender {
    [self showHelp];

}
@end
