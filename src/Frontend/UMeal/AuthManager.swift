//
//  AuthManager.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/30/26.
//

import SwiftUI
import Supabase
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var username = ""
    
    // SIGN UP
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            // Create user_profile row after signup
            let userId = response.user.id.uuidString
            try await supabase
                .from("user_profile")
                .insert([
                    "user_id": userId
                ])
                .execute()
            
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // LOGIN
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            // Fetch user_profile
            let userId = session.user.id.uuidString
            username = session.user.email ?? "User"
            
            isLoggedIn = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // LOGOUT
    func logout() async {
        do {
            try await supabase.auth.signOut()
            isLoggedIn = false
            username = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // CHECK SESSION on app launch
    func checkSession() async {
        let session = try? await supabase.auth.session
        if let session = session {
            isLoggedIn = true
            username = session.user.email ?? "User"
        }
    }
}
