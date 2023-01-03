//
//  AppDelegate.swift
//  ThinkLess
//
//  Created by Ashil Ramjee on 2022/12/29.
//

import AppKit
import Cocoa
import CoreGraphics
import Accessibility

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var tapCreated = false
    var runLoopSource: CFRunLoopSource!
    let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue) // blocks keydown values, and flags that are changed, etc caps lock and other buttons
    var eventTap: CFMachPort?
    
    // runs when application starts - requests accessability trust
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options: [String: Any] = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !trusted {
            let alert = NSAlert()
            alert.messageText = "Accessibility Access Required"
            alert.informativeText = "Please grant accessibility access to use the app. Once granted youi may need to restart the app."
            alert.addButton(withTitle: "Quit")
            alert.addButton(withTitle: "Open Accessibility Settings")
            
            let response = alert.runModal()
            if response == .alertSecondButtonReturn {
                // Open the accessibility menu if the user clicks the "Open Accessibility Settings" button.
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            } else if response == .alertFirstButtonReturn {
                exit(0)
            }
        } else {
            let path = Bundle.main.bundlePath
            let url = URL(fileURLWithPath: path)
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.arguments = []
            NSWorkspace.shared.openApplication(at: url, configuration: configuration) { (success, error) in
                if (success != nil) {
                    // App launched successfully.
                } else {
                    let alert = NSAlert()
                    alert.messageText = "App failed to restart."
                    alert.informativeText = "App failed to restart. Please make sure access was granted and restart the app."
                    alert.addButton(withTitle: "Quit")
                    
                    let response = alert.runModal()
                    
                    if response == .alertFirstButtonReturn {
                        exit(0)
                    }
                }
            }
        }
    }
    
    // setup tap or enble/ disable it
    func toggleKeyboardLock(isOn: Bool) {
        if (isOn == true) {
            if (tapCreated == false) {
                setupTap()
            } else {
                CGEvent.tapEnable(tap: eventTap!, enable: true)
            }
        } else {
            if (tapCreated == true) {
                CGEvent.tapEnable(tap: eventTap!, enable: false)
            }
        }
    }
    
    // creates an event tap
    func setupTap() {
        eventTap = CGEvent.tapCreate(tap: .cghidEventTap, place: .headInsertEventTap, options: .defaultTap, eventsOfInterest: CGEventMask(eventMask), callback: { proxy, type, event, refcon in
            return nil // blocks the given event masks
            //return Unmanaged.passRetained(event) // default event
        }, userInfo: nil)
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        
        CGEvent.tapEnable(tap: eventTap!, enable: true)
        tapCreated = true
        
        CFRunLoopRun()
    }
}
