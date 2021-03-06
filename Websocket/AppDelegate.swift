//
//  AppDelegate.swift
//  Websocket
//
//  Created by Benjamin Pisano on 18/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func newWindow(_ sender: Any) {
        let storyboard: NSStoryboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController: NSWindowController = storyboard.instantiateInitialController() as! NSWindowController
        windowController.showWindow(self)
    }
    
}
