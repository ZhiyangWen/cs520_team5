import SwiftUI

// Colors
extension Color {
    static let maroonPrimary = Color(red: 0.369, green: 0.008, blue: 0.008) // #5E0202
    static let crimsonAccent = Color(red: 0.647, green: 0.000, blue: 0.204) // #A50034
    static let coolGray      = Color(red: 0.541, green: 0.608, blue: 0.659) // #8A9BA8
}

struct LoginView: View {
    @State private var email: String    = ""
    @State private var password: String = ""
    @State private var isLoading: Bool  = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        // Our logo
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                            // Imported from figma
                            Image("Vector")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.white)
                        }

                        Text("UMeal")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    .background(Color.maroonPrimary)

            
                    VStack(spacing: 30) {
                        // Email field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("University Email")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.black)
                            TextField("student@umass.edu", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(12)
                                .frame(height: 60)
                                .background(Color(.systemBackground))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color(.systemGray4), lineWidth: 2)
                                )
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Password")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.black)
                            SecureField("••••••••", text: $password)
                                .padding(12)
                                .frame(height: 60)
                                .background(Color(.systemBackground))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color(.systemGray4), lineWidth: 2)
                                )
                        }

                        // Forgot password
                        HStack {
                            Spacer()
                            Button("Forget password?") {
                                // TODO: Handle forget password right here
                            }
                            .font(.system(size: 13 ,weight: .semibold))
                            .foregroundColor(Color.crimsonAccent)
                        }

                        // Sign In button
                        Button {
                            handleSignIn()
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.crimsonAccent)
                            .cornerRadius(25)
                        }
                        .disabled(isLoading)

                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Color(.systemGray4))
                            Text("don't have an account?")
                                .font(.system(size: 12))
                                .foregroundColor(Color(.systemGray))
                                .fixedSize()
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Color(.systemGray4))
                        }

                        // Create account
                        NavigationLink(destination: Text("Sign Up")) {
                            Text("Create account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.maroonPrimary)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 36)
                    .padding(.bottom, 40)
                    .background(Color(.systemGray6))

                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func handleSignIn() {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        // TODO: Authentication API right here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
}
//  LoginView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 3/31/26.
//

