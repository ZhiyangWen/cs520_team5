//
//  LandingView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/1/26.
//

import SwiftUI

struct DiningHallInfo: Identifiable {
    let id = UUID()
    let name: String
    let openHour: Int
    let closeHour: Int
    let hoursDisplay: String
    var isOpen: Bool {
        let cur_hour = Calendar.current.component(.hour, from: Date())
        return cur_hour >= openHour && cur_hour < closeHour
    }
}

struct LandingView: View {
    @AppStorage("proteinTarget") private var proteinTarget: Int = 120
    @AppStorage("dailyCalories") private var dailyCalories: Int = 1000
    @StateObject private var menuService = DiningMenuService()
    @State private var navigateToProfile = false
    @EnvironmentObject private var auth: AuthManager

    @State private var selectedFilter = "All"
    let filters = ["All", "High Protein", "Vegetarian", "Halal", "Low Calorie"]

    let diningHalls = [
        DiningHallInfo(name: "Worcester Commons",
                   openHour: 7, closeHour: 21,
                   hoursDisplay: "07:00 AM - 09:00 PM"),
        DiningHallInfo(name: "Franklin Dining Commons",
                   openHour: 7, closeHour: 21,
                   hoursDisplay: "07:00 AM - 09:00 PM"),
        DiningHallInfo(name: "Berkshire Dining Commons",
                   openHour: 11, closeHour: 21,
                   hoursDisplay: "11:00 AM - 09:00 PM"),
        DiningHallInfo(name: "Hampshire Dining Commons",
                   openHour: 7, closeHour: 21,
                   hoursDisplay: "07:00 AM - 09:00 PM")
    ]
    
    var userName: String { auth.fullName.components(separatedBy: " ").first ?? "User" }
    
    var userInitials: String {
        let parts = auth.fullName.components(separatedBy: " ")
        return parts.compactMap { $0.first }.prefix(2).map(String.init).joined().uppercased()
    }

    var todaysMeals: [DiningMeal] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())

        let filtered = menuService.meals.filter { meal in
            guard meal.date == today else { return false }
            switch selectedFilter {
            case "High Protein":
                let perMeal = Double(proteinTarget) / 10.0
                return (meal.protein ?? 0) >= perMeal
            case "Vegetarian":
                return meal.dietaryFlags.isVegetarian || meal.dietaryFlags.isVegan
            case "Halal":
                return meal.dietaryFlags.isHalal
            case "Low Calorie":
                let perMeal = dailyCalories / 3
                return (meal.calories ?? 999) <= perMeal
            default:
                return true
            }
        }
        return Array(filtered.prefix(4))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Text("UMeal")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Hi, \(userName) 👋")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.9))
                        // Profile button
                        Button {
                            navigateToProfile = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.crimson)
                                    .frame(width: 36, height: 36)
                                Text(userInitials)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .accessibilityIdentifier("profileButton")
                        .navigationDestination(isPresented: $navigateToProfile) {
                            ProfileView()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(Color.maroon)
                .padding(.top, 60)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Dining Halls
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Dining Halls")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.maroon)
                            ForEach(diningHalls) { hall in
                                DiningHallCard(hall: hall)
                            }
                        }

                        // Filter
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Filter")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.maroon)
                            FlowLayout(filters: filters, selected: $selectedFilter)
                        }

                        // Today's Recommendations
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Today's Recommendations")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.maroon)
                                .accessibilityIdentifier("recommendationsTitle")

                            if menuService.isLoading {
                                // Show loading spinner while scraping
                                HStack {
                                    Spacer()
                                    ProgressView("Loading menu...")
                                    Spacer()
                                }
                                .padding()
                            } else if todaysMeals.isEmpty {
                                // Show message if no meals found
                                Text("No meals available today.")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 14))
                                    .padding()
                                    .accessibilityIdentifier("noMealsText")

                            } else {
                                // Show real scraped meals
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 12) {
                                    ForEach(todaysMeals, id: \.name) { meal in
                                        MealCard(meal: meal)
                                    }
                                }
                                .accessibilityIdentifier("mealsGrid")
                            }
                        }

                        // Explore More
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Explore More")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.maroon)
                            HStack(spacing: 12) {
                                NavigationLink(destination: RecipeSearchView()) {
                                    ExploreButton(icon: "magnifyingglass",
                                                 title: "Search Recipes",
                                                 color: Color.maroon)
                                }
                                NavigationLink(destination: Text("Post Recipe")) {
                                    ExploreButton(icon: "plus",
                                                 title: "Post Recipe",
                                                 color: Color.crimson)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                }
                .background(Color(.systemGray6))
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .top)
            .task {
                await menuService.loadOnLaunch()
            }
        }
    }
}

// Dining Hall Card
struct DiningHallCard: View {
    let hall: DiningHallInfo

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(hall.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text(hall.hoursDisplay)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            Text(hall.isOpen ? "Open" : "Closed")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(hall.isOpen ? .green : .white.opacity(0.6))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.15))
                .cornerRadius(20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(hall.isOpen ? Color.maroon : Color.maroon.opacity(0.6))
        .cornerRadius(25)
    }
}

// New MealCard using real DiningMeal data
struct MealCard: View {
    let meal: DiningMeal
    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.maroon.opacity(0.3))
                .frame(height: 70)

            Text(meal.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)

            if let calories = meal.calories {
                Text("Calories \(calories)")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.8))
            }

            if let protein = meal.protein {
                Text("Protein \(protein, specifier: "%.1f")g")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.8))
            }

            HStack {
                // Dietary flags
                if meal.dietaryFlags.isVegetarian {
                    Text("V")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.green)
                }
                if meal.dietaryFlags.isHalal {
                    Text("H")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.yellow)
                }
                Spacer()
                Button {
                    isSaved.toggle()
                } label: {
                    Image(systemName: isSaved ? "star.fill" : "star")
                        .font(.system(size: 18))
                        .foregroundStyle(.yellow)
                }
                .accessibilityIdentifier("saveButton_\(meal.name)")
            }
        }
        .padding(10)
        .background(Color.maroon)
        .cornerRadius(12)
    }
}

// Filter
struct FlowLayout: View {
    let filters: [String]
    @Binding var selected: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(filters.prefix(3), id: \.self) { filter in
                    FilterChip(title: filter, isSelected: selected == filter) {
                        selected = filter
                    }
                }
            }
            HStack(spacing: 8) {
                ForEach(filters.dropFirst(3), id: \.self) { filter in
                    FilterChip(title: filter, isSelected: selected == filter) {
                        selected = filter
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isSelected ? .white : Color.crimson)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.crimson : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.crimson, lineWidth: 1.5)
                )
        }
        .accessibilityIdentifier("filter_\(title)")
    }
}

// Explore
struct ExploreButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color)
        .cornerRadius(14)
    }
}

#Preview {
    LandingView()
}
