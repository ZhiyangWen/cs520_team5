//  ProfileView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/2/26.


import SwiftUI

// Profile Header
private struct ProfileHeaderView: View {
    let onBack: () -> Void

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
                Spacer()
            }
            .padding(.horizontal, 20)

            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 90, height: 90)
                    .overlay(
                        Text("ZW")
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

            Text("Zhiyang Wen")
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
    @State private var dailyCalories: Int = 1000
    @State private var proteinTarget: Int = 120
    @State private var restrictions: [String] = ["Nut Allergy", "Vegan"]
    @State private var newMenuAlerts: Bool = true
    @State private var showingCaloriesEditor = false
    @State private var showingProteinEditor = false
    @State private var showingAddRestriction = false
    @State private var newRestriction: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                ProfileHeaderView(onBack: { dismiss() })

                VStack(alignment: .leading, spacing: 24) {

                    // Nutrition Goals
                    sectionHeader("Nutrition Goals")

                    VStack(spacing: 12) {
                        nutritionRow(label: "Daily Calories", value: "\(dailyCalories) kcal") {
                            showingCaloriesEditor = true
                        }
                        nutritionRow(label: "Protein Target", value: "\(proteinTarget) g") {
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
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.maroon)
                    .cornerRadius(14)

                    // Save Button
                    Button {
                        // TODO: Save changes
                    } label: {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.crimson)
                            .cornerRadius(30)
                    }
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
        .alert("Edit Daily Calories", isPresented: $showingCaloriesEditor) {
            TextField("Calories", value: $dailyCalories, format: .number)
                .keyboardType(.numberPad)
            Button("Save") {}
            Button("Cancel", role: .cancel) {}
        }
        .alert("Edit Protein Target", isPresented: $showingProteinEditor) {
            TextField("Grams", value: $proteinTarget, format: .number)
                .keyboardType(.numberPad)
            Button("Save") {}
            Button("Cancel", role: .cancel) {}
        }
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
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}

