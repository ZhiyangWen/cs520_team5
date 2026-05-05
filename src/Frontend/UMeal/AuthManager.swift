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
    @Published var fullName = ""
    @Published var userId: UUID? = nil

    // SIGN UP
    func signUp(email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            let userId = response.user.id
            try await supabase
                .from("user_profile")
                .insert(["user_id": userId.uuidString, "full_name": fullName])
                .execute()

            self.userId = userId
            self.fullName = fullName
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
            let userId = session.user.id
            self.userId = userId
            username = session.user.email ?? "User"

            // Fetch full_name from user_profile
            let profiles: [[String: String]] = try await supabase
                .from("user_profile")
                .select("full_name")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            self.fullName = profiles.first?["full_name"] ?? "User"

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
            fullName = ""
            userId = nil  
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // CHECK SESSION
    func checkSession() async {
        guard let session = try? await supabase.auth.session else { return }
        let userId = session.user.id
        self.userId = userId  // ADD THIS
        username = session.user.email ?? "User"
        isLoggedIn = true

        // Fetch full_name
        let profiles: [[String: String]] = (try? await supabase
            .from("user_profile")
            .select("full_name")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value) ?? []
        self.fullName = profiles.first?["full_name"] ?? "User"
    }
}
