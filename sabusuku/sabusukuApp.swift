//
//  sabusukuApp.swift
//  sabusuku
//
//  Created by hashimo ryoya on 2023/09/05.
//

import SwiftUI
import Firebase

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}

@main
struct sabusukuApp: App {
    lazy var authManager: AuthManager = AuthManager.shared

    init() {
        FirebaseApp.configure()
        AuthManager.shared = AuthManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
