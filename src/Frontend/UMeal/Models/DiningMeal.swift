// Models/DiningMeal.swift
// UMeal – CS520 Team 5
// Author: Pornnapin Tangkoskul

import Foundation

// MARK: - Enums

/// The four UMass residential dining commons.
enum DiningHall: String, CaseIterable, Codable {
    case berkshire  = "berkshire"
    case worcester  = "worcester"
    case franklin   = "franklin"
    case hampshire  = "hampshire"

    /// Human-readable display name.
    var displayName: String {
        switch self {
        case .berkshire:  return "Berkshire Dining Commons"
        case .worcester:  return "Worcester Dining Commons"
        case .franklin:   return "Franklin Dining Commons"
        case .hampshire:  return "Hampshire Dining Commons"
        }
    }

    /// URL slug used on umassdining.com.
    var urlSlug: String { rawValue }
}

/// Meal periods served at each dining commons.
enum MealPeriod: String, CaseIterable, Codable {
    case breakfast  = "Breakfast"
    case lunch      = "Lunch"
    case dinner     = "Dinner"
    case lateNight  = "Late Night"

    /// Returns a MealPeriod by matching common text patterns found in the HTML.
    static func from(rawText: String) -> MealPeriod? {
        let lower = rawText.lowercased()
        if lower.contains("breakfast")           { return .breakfast }
        if lower.contains("late night") || lower.contains("latenight") { return .lateNight }
        if lower.contains("lunch") || lower.contains("brunch") { return .lunch }
        if lower.contains("dinner")              { return .dinner }
        return nil
    }
}

/// Structured dietary flags extracted per meal item.
struct DietaryFlags: Codable, Equatable {
    var isVegan:       Bool = false
    var isVegetarian:  Bool = false
    var isGlutenFree:  Bool = false
    var isHalal:       Bool = false
    var isKosher:      Bool = false
    /// Free-form allergen strings, e.g. ["Milk", "Wheat/Gluten", "Soy"]
    var allergens:     [String] = []

    var isEmpty: Bool {
        !isVegan && !isVegetarian && !isGlutenFree && !isHalal && !isKosher && allergens.isEmpty
    }
}

// MARK: - Core Model

/// A single menu item served at a UMass dining commons.
struct DiningMeal: Codable, Identifiable {
    let id:            UUID
    let name:          String
    let hall:          DiningHall
    let date:          String          // "YYYY-MM-DD"
    let mealPeriod:    MealPeriod
    let station:       String?         // e.g. "Sauté Station", nil if unavailable
    var dietaryFlags:  DietaryFlags
    var calories:      Int?
    var protein:       Double?         // grams
    var carbs:         Double?         // grams
    var fat:           Double?         // grams

    init(
        id:           UUID         = UUID(),
        name:         String,
        hall:         DiningHall,
        date:         String,
        mealPeriod:   MealPeriod,
        station:      String?      = nil,
        dietaryFlags: DietaryFlags = DietaryFlags(),
        calories:     Int?         = nil,
        protein:      Double?      = nil,
        carbs:        Double?      = nil,
        fat:          Double?      = nil
    ) {
        self.id           = id
        self.name         = name
        self.hall         = hall
        self.date         = date
        self.mealPeriod   = mealPeriod
        self.station      = station
        self.dietaryFlags = dietaryFlags
        self.calories     = calories
        self.protein      = protein
        self.carbs        = carbs
        self.fat          = fat
    }
}
