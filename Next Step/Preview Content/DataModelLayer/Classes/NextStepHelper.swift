//
//  NextStepHelper.swift
//  Next Step
//
//  Created by Jan on 19/12/2024.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

class HelperClass{
    static func getSystemBackgroundColor() -> Color {
            #if os(iOS)
            return Color(UIColor.systemBackground)
            #elseif os(macOS)
            return Color(NSColor.windowBackgroundColor)
            #endif
        }
    
    static func calculateProgress(task: TaskModel) -> Double {
        
        let completedTask: Int = task.subTasks.filter{$0.isCompleted}.count
        let allTask: Int = task.subTasks.count
        
        guard allTask > 0 else { return 0.0 }
        
        let result = (Double(completedTask) / Double(allTask));
        
        return result;
    }
    
    static func dynamicBackgroundColor() -> Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground) // iOS-specific dynamic color
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)    // macOS-specific dynamic color
        #endif
    }
}
