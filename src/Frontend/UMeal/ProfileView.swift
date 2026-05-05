//  ProfileView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/2/26.


//  ProfileView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/2/26.

import SwiftUI

// Profile Header
private struct ProfileHeaderView: View {
    let onBack: () -> Void
    @EnvironmentObject private var auth: AuthManager

    var initials: String {
        auth.fullName
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
            .uppercased()
    }

    var body: some View {
        VStack(spacing: 12) {
            // Back button row
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                }
                .accessibilityIdentifier("backButton")
                Spacer()
            }
            .padding(.horizontal, 20)

            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    )
                Circle()
                    .fill(Color.crimson)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }

            Text(auth.fullName.isEmpty ? "User" : auth.fullName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 0) {
                statItem(value: "20", label: "Saved")
                statItem(value: "3", label: "Recipes")
                statItem(value: "6", label: "Reviews")
            }
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.bottom, 30)
        .background(Color.maroon)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// Profile View
struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var auth: AuthManager

    @AppStorage("dailyCalories") private var dailyCalories: Int = 1000
    @AppStorage("proteinTarget") private var proteinTarget: Int = 120
    @AppStorage("newMenuAlerts") private var newMenuAlerts: Bool = true

    @State private var restrictions: [String] = {
        let saved = UserDefaults.standard.stringArray(forKey: "restrictions")
        return saved ?? ["Nut Allergy", "Vegan"]
    }()

    @State private var showingCaloriesEditor = false
    @State private var showingProteinEditor = false
    @State private var showingAddRestriction = false
    @State private var newRestriction: String = ""
    @State private var showingSaveSuccess = false
    @State private var showingCaloriesError = false
    @State private var showingProteinError = false

    // Temporary values for editing
    @State private var tempCalories: Int = 1000
    @State private var tempProtein: Int = 120

    // NEW: loading state for Supabase
    @State private var isLoadingProfile = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                ProfileHeaderView(onBack: { dismiss() })
                    .environmentObject(auth)

                VStack(alignment: .leading, spacing: 24) {

                    // Nutrition Goals
                    sectionHeader("Nutrition Goals")

                    VStack(spacing: 12) {
                        nutritionRow(label: "Daily Calories", value: "\(dailyCalories) kcal") {
                            tempCalories = dailyCalories
                            showingCaloriesEditor = true
                        }
                        nutritionRow(label: "Protein Target", value: "\(proteinTarget) g") {
                            tempProtein = proteinTarget
                            showingProteinEditor = true
                        }
                    }

                    // Dietary Restrictions
                    sectionHeader("Dietary Restrictions")

                    restrictionsSection

                    // Notifications
                    sectionHeader("Notifications")

                    HStack {
                        Text("New menu alerts")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $newMenuAlerts)
                            .tint(Color.crimson)
                            .accessibilityIdentifier("newMenuAlertsToggle")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.maroon)
                    .cornerRadius(14)

                    // Success message
                    if showingSaveSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Changes saved successfully!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .transition(.opacity)
                        .accessibilityIdentifier("saveSuccessMessage")
                    }

                    // Save Button — UPDATED to also save to Supabase
                    Button {
                        Task {
                            await saveProfileToSupabase()
                        }
                    } label: {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.crimson)
                            .cornerRadius(30)
                    }
                    .accessibilityIdentifier("saveChangesButton")
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .background(Color(.systemGray6))
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        // Load profile from Supabase on appear
        .onAppear {
            Task {
                await loadProfileFromSupabase()
            }
        }
        // Edit Calories Alert
        .alert("Edit Daily Calories", isPresented: $showingCaloriesEditor) {
            TextField("Calories", value: $tempCalories, format: .number)
                .keyboardType(.numberPad)
            Button("Save") {
                if tempCalories <= 0 {
                    showingCaloriesError = true
                } else {
                    dailyCalories = tempCalories
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your daily calorie goal.")
        }
        // Edit Protein Alert
        .alert("Edit Protein Target", isPresented: $showingProteinEditor) {
            TextField("Grams", value: $tempProtein, format: .number)
                .keyboardType(.numberPad)
            Button("Save") {
                if tempProtein <= 0 {
                    showingProteinError = true
                } else {
                    proteinTarget = tempProtein
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your daily protein goal in grams.")
        }
        // Calories Error Alert
        .alert("Invalid Input", isPresented: $showingCaloriesError) {
            Button("Try Again") {
                showingCaloriesEditor = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Daily calories must be greater than 0. Please enter a valid number.")
        }
        // Protein Error Alert
        .alert("Invalid Input", isPresented: $showingProteinError) {
            Button("Try Again") {
                showingProteinEditor = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Protein target must be greater than 0. Please enter a valid number.")
        }
        // Add Restriction Alert
        .alert("Add Restriction", isPresented: $showingAddRestriction) {
            TextField("e.g. Gluten Free", text: $newRestriction)
            Button("Add") {
                if !newRestriction.isEmpty {
                    restrictions.append(newRestriction)
                    newRestriction = ""
                }
            }
            Button("Cancel", role: .cancel) { newRestriction = "" }
        }
    }

    // Restrictions Section
    private var restrictionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(restrictions, id: \.self) { restriction in
                restrictionTag(restriction)
            }
            Button {
                showingAddRestriction = true
            } label: {
                Text("+ Add Restriction")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                            .foregroundColor(.white.opacity(0.6))
                    )
            }
            .accessibilityIdentifier("addRestrictionButton")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.maroon)
        .cornerRadius(14)
    }

    // Helpers
    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.black)
    }

    @ViewBuilder
    private func nutritionRow(label: String, value: String, onEdit: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
            Button(action: onEdit) {
                Text("Edit")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.crimson)
                    .cornerRadius(20)
            }
            .accessibilityIdentifier("edit\(label.replacingOccurrences(of: " ", with: ""))Button")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.maroon)
        .cornerRadius(14)
    }

    @ViewBuilder
    private func restrictionTag(_ text: String) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            Button {
                restrictions.removeAll { $0 == text }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .accessibilityIdentifier("remove_\(text)")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
    }

    // Supabase Functions

    private func loadProfileFromSupabase() async {
        guard let userId = auth.userId else { return }
        isLoadingProfile = true
        do {
            if let profile = try await UserProfileService.loadProfile(userId: userId) {
                if let cal = profile.maxCalories { dailyCalories = cal }
                if let pro = profile.minProtein { proteinTarget = pro }
                if let allergies = profile.allergies, !allergies.isEmpty {
                    restrictions = allergies
                }
            }
        } catch {
            print("Failed to load profile: \(error)")
        }
        isLoadingProfile = false
    }

    // Saves profile data to Supabase and shows success message
    private func saveProfileToSupabase() async {
        guard let userId = auth.userId else {
            print("No userId found!")
            // Fallback to local save if not logged in
            UserDefaults.standard.set(restrictions, forKey: "restrictions")
            withAnimation { showingSaveSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showingSaveSuccess = false }
            }
            return
        }
        print("Saving profile for userId: \(userId)")
        do {
            try await UserProfileService.saveProfile(
                userId: userId,
                maxCalories: dailyCalories,
                minProtein: proteinTarget,
                allergies: restrictions
            )
            // Also save locally as backup
            UserDefaults.standard.set(restrictions, forKey: "restrictions")
            withAnimation { showingSaveSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showingSaveSuccess = false }
            }
            print("Profile saved successfully!")
        } catch {
            print("Failed to save profile: \(error)")
            // Still save locally and show success
            UserDefaults.standard.set(restrictions, forKey: "restrictions")
            withAnimation { showingSaveSuccess = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showingSaveSuccess = false }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthManager())
    }
}
