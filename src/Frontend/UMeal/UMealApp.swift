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
            if auth.isLoggedIn {
                LandingView()
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
