//
//  AppDelegate.h
//  Kill
//
//  Created by Rene Dohan on 2/16/13.
//  Copyright (c) 2013 creative_studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>{
    NSStatusItem * statusItem;
}

@property (assign) IBOutlet NSMenu *menu;
@property (strong) IBOutlet NSWindow *about;
@property (strong) IBOutlet NSWindow *help;
- (IBAction)onAboutClick:(id)sender;
- (IBAction)onQuitClick:(id)sender;
- (IBAction)onCreativeSoftwareClick:(id)sender;
- (IBAction)onNameClick:(id)sender;
- (IBAction)onToggleLogin:(NSMenuItem *)sender;
@property (weak) IBOutlet NSMenuItem *menuItemToggleLaunchOnLogin;
- (IBAction)onHelpClick:(id)sender;

@end
