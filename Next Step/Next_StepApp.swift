//
//  Next_StepApp.swift
//  Next Step
//
//  Created by Jan on 19/11/2024.
//

import SwiftUI
import Firebase
import SwiftData

@main
struct Next_StepApp: App {

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #elseif os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    #endif
    
    @AppStorage("userID") var userID: String?
    
    var body: some Scene {
        WindowGroup {
            if((userID?.isEmpty) != nil){
                HomeView()
            }
            else{
                LoginView()
            }
        }
        .modelContainer(for: [TaskModel.self, TechniqueModel.self])
    }
}


#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
#elseif os(macOS)
    class AppDelegate: NSObject, NSApplicationDelegate {
        
        // This method is called when the application finishes launching
        func applicationDidFinishLaunching(_ notification: Notification) {
            // Initialize Firebase (or any other services)
            FirebaseApp.configure()
            print("App has finished launching and Firebase is configured!")
        }
    }
#endif
