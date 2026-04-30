//
//  SignUpView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/20/26.


import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmedPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var showPasswordMismatch: Bool = false

    var body: some View {
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
                    Text("Create Account")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                .padding(.bottom, 40)
                .background(Color.maroon)

                // Form
                VStack(spacing: 24) {

                    // Full Name
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Full Name")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.black)
                        TextField("", text: $fullName)
                            .autocapitalization(.words)
                            .padding(12)
                            .frame(height: 60)
                            .background(Color(.systemBackground))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color(.systemGray4), lineWidth: 2)
                            )
                    }

                    // University Email
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

                    // Password
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

                    // Confirmed Password
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Confirmed Password")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.black)
                        SecureField("", text: $confirmedPassword)
                            .padding(12)
                            .frame(height: 60)
                            .background(Color(.systemBackground))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        showPasswordMismatch ? Color.red : Color(.systemGray4),
                                        lineWidth: 2
                                    )
                            )
                        if showPasswordMismatch {
                            Text("Passwords do not match")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                                .padding(.leading, 12)
                        }
                    }

                    // Create Account Button
                    Button {
                        handleSignUp()
                    } label: {
                        Group {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.crimson)
                        .cornerRadius(25)
                    }
                    .disabled(isLoading)

                    // Already have account
                    HStack {
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color(.systemGray4))
                        Text("already have an account?")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.systemGray))
                            .fixedSize()
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color(.systemGray4))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Sign in")
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

    private func handleSignUp() {
        showPasswordMismatch = false
        guard !fullName.isEmpty, !email.isEmpty, !password.isEmpty else { return }
        guard password == confirmedPassword else {
            showPasswordMismatch = true
            return
        }
        isLoading = true
        // TODO: Registration API call here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}


