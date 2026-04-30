//
//  LandingView.swift
//  UMeal
//
//  Created by Zhiyang Wen on 4/1/26.
//

import SwiftUI

struct DiningHall: Identifiable {
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


struct Recommendation: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let rating: Int
}


struct LandingView: View {
    let userName = "Zhiyang"
    let userInitials = "ZW"

    @State private var selectedFilter = "All"
    let filters = ["All", "High Protein", "Vegan", "Low Calories"] // Could have more options

    let diningHalls = [
        DiningHall(name: "Worcester Commons",
                   openHour: 7, closeHour: 21,
                   hoursDisplay: "07:00 AM - 09:00 PM"),
        DiningHall(name: "Franklin Dining Commons",
                   openHour: 7, closeHour: 21,
                   hoursDisplay: "07:00 AM - 09:00 PM"),
        DiningHall(name: "Berkshire Dining Commons",
                   openHour: 11, closeHour: 21,
                   hoursDisplay: "11:00 AM - 09:00 PM"),
        DiningHall(name: "Hampshire Dining Commons",
                   openHour: 7, closeHour: 21,
                   hoursDisplay: "07:00 AM - 09:00 PM")
    ]

    let recommendations = [
        // TODO
        Recommendation(name: "Baked Chicken Thigh",
                       calories: 121, protein: 14.2, rating: 2),
        Recommendation(name: "Caesar Salad",
                       calories: 95, protein: 8.0, rating: 4)
    ]

    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed Header
                HStack {
                    Text("UMeal")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Hi, \(userName) 👋")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.9))
                        NavigationLink(destination: Text(" User Profile")){
                            ZStack {
                                Circle()
                                    .fill(Color.crimson)
                                    .frame(width: 36, height: 36)
                                Text(userInitials)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(Color.maroon)
                .padding(.top, 60)

                // All scrollable content below header
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
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(recommendations) { rec in
                                    RecommendationCard(rec: rec)
                                }
                            }
                        }

                        // Explore More
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Explore More")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.maroon)
                            HStack(spacing: 12) {
                                NavigationLink(destination: Text("Recipe Search")) {
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
        }
    }
}

// Dining Hall
struct DiningHallCard: View {
    let hall: DiningHall

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
    }
}

// Recommendation
struct RecommendationCard: View {
    let rec: Recommendation
    @State private var isSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.maroon.opacity(0.3))
                .frame(height: 70)

            Text(rec.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
            Text("Calories \(rec.calories)")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.8))
            Text("Protein \(rec.protein, specifier: "%.1f")g")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.8))

            HStack {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rec.rating ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                Spacer()
                Button {
                    isSaved.toggle()
                } label: {
                    Image(systemName: isSaved ? "star.fill" : "star")
                        .font(.system(size: 18))
                        .foregroundStyle(.yellow)
                }
            }
        }
        .padding(10)
        .background(Color.maroon)
        .cornerRadius(12)
    }
}
   

//Explore
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
