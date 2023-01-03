//
//  ThinkLessApp.swift
//  ThinkLess
//
//  Created by Ashil Ramjee on 2022/12/29.
//

import SwiftUI
import AppKit

@main
struct ThinkLessApp: App {
    @State var currentStatus: String = "lock.open"
    @State var keyboardLocked = false
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        let binding = Binding(
            get: { self.keyboardLocked },
            set: { value in
                if (self.keyboardLocked == true) {
                    self.keyboardLocked = false
                    currentStatus = "lock.open"
                    appDelegate.toggleKeyboardLock(isOn: false)
                }
                else {
                    self.keyboardLocked = true
                    currentStatus = "lock"
                    appDelegate.toggleKeyboardLock(isOn: true)
                }
            }
        )
        
        MenuBarExtra(currentStatus, systemImage: "\(currentStatus)") {
            Toggle(isOn: binding){
                Text("Keyboard Locked")
                
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }
}

