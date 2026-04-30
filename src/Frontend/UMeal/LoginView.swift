//  LoginView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 3/31/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
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
                    .background(Color.maroon)

                    VStack(spacing: 30) {
                        // Email field
                        VStack(alignment: .leading, spacing: 10) {
                            Text("University Email")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.black)
                            TextField("", text: $email)
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
                            SecureField("", text: $password)
                                .padding(12)
                                .frame(height: 60)
                                .background(Color(.systemBackground))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color(.systemGray4), lineWidth: 2)
                                )
                        }

                        
                        if !auth.errorMessage.isEmpty {
                            Text(auth.errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 13))
                                .multilineTextAlignment(.center)
                        }

                        // Forgot password
                        HStack {
                            Spacer()
                            Button("Forget password?") {
                                // TODO: Handle forget password
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.crimson)
                        }

                        // Sign In button
                        Button {
                            handleSignIn()
                        } label: {
                            Group {
                                if auth.isLoading {
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
                            .background(Color.crimson)
                            .cornerRadius(25)
                        }
                        .disabled(auth.isLoading)  

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
                        NavigationLink(destination: SignUpView()) {
                            Text("Create account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.maroon)
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
        Task {
            await auth.login(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
