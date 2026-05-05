//
//  UMealApp.swift
//  UMeal
//
//  Created by Zhiyang Wen on 3/31/26.
//

import SwiftUI

@main
struct UMealApp: App {
    @StateObject private var auth = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("UI_TESTING") || auth.isLoggedIn {
                LandingView()
                    .environmentObject(auth) 
            } else {
                LoginView()
                    .environmentObject(auth)
                    //.task {
                        //await auth.checkSession()
                    //}
            }
        }
    }
}
