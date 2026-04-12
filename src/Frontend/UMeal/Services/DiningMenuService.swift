// Services/DiningMenuService.swift
// UMeal – CS520 Team 5
// Author: Pornnapin Tangkoskul
//
// App-facing service that coordinates scraping, caching, and data access.
// ViewModels should depend on this class, not on the scraper directly.

import Foundation

@MainActor
final class DiningMenuService: ObservableObject {

    // MARK: - Published State

    @Published var meals:       [DiningMeal] = []
    @Published var isLoading:   Bool         = false
    @Published var lastError:   String?      = nil

    // MARK: - Private

    private let scraper = UMassDiningScraper()

    // MARK: - Lifecycle

    /// Call on app launch.
    /// Loads cache immediately for fast UI, then refreshes in background if stale.
    func loadOnLaunch() async {
        // 1. Load cached data instantly so UI has something to show
        let cached = DiningCache.loadAll()
        if !cached.isEmpty {
            meals = cached
        }

        // 2. Check if any hall is stale
        let staleHalls = DiningHall.allCases.filter { DiningCache.isStale(for: $0) }
        guard !staleHalls.isEmpty else {
            print("All halls are fresh — using cache only.")
            return
        }

        // 3. Refresh stale halls in background
        isLoading = true
        defer { isLoading = false }

        let results = await scraper.fetchAllHalls(forceRefresh: false)
        integrate(results: results)
    }

    /// Force a full re-scrape of all halls (e.g. user pulls to refresh).
    func forceRefresh() async {
        isLoading = true
        defer { isLoading = false }
        lastError = nil

        let results = await scraper.fetchAllHalls(forceRefresh: true)
        integrate(results: results)
    }

    // MARK: - Query Helpers

    /// Returns meals for a specific hall and date string ("YYYY-MM-DD").
    func meals(for hall: DiningHall, date: String) -> [DiningMeal] {
        meals.filter { $0.hall == hall && $0.date == date }
    }

    /// Returns meals grouped by meal period for a given hall and date.
    func mealsByPeriod(for hall: DiningHall, date: String) -> [MealPeriod: [DiningMeal]] {
        Dictionary(grouping: meals(for: hall, date: date), by: \.mealPeriod)
    }

    /// Filters meals by dietary flags and optional calorie/protein thresholds.
    func filteredMeals(
        hall:         DiningHall?   = nil,
        date:         String?       = nil,
        period:       MealPeriod?   = nil,
        veganOnly:    Bool          = false,
        vegetarianOnly: Bool        = false,
        glutenFreeOnly: Bool        = false,
        halalOnly:    Bool          = false,
        kosherOnly:   Bool          = false,
        maxCalories:  Int?          = nil,
        minProtein:   Double?       = nil,
        excludeAllergens: [String]  = []
    ) -> [DiningMeal] {
        meals.filter { meal in
            if let h = hall,   meal.hall != h          { return false }
            if let d = date,   meal.date != d          { return false }
            if let p = period, meal.mealPeriod != p    { return false }
            if veganOnly,      !meal.dietaryFlags.isVegan        { return false }
            if vegetarianOnly, !meal.dietaryFlags.isVegetarian   { return false }
            if glutenFreeOnly, !meal.dietaryFlags.isGlutenFree   { return false }
            if halalOnly,      !meal.dietaryFlags.isHalal        { return false }
            if kosherOnly,     !meal.dietaryFlags.isKosher       { return false }
            if let max = maxCalories, let cal = meal.calories, cal > max { return false }
            if let min = minProtein,  let pro = meal.protein,  pro < min { return false }
            for allergen in excludeAllergens {
                if meal.dietaryFlags.allergens
                    .contains(where: { $0.lowercased().contains(allergen.lowercased()) }) {
                    return false
                }
            }
            return true
        }
    }

    // MARK: - Private

    private func integrate(results: [HallScrapeResult]) {
        // Merge new meals into our state, replacing old data for each hall
        for result in results {
            meals.removeAll { $0.hall == result.hall }
            meals.append(contentsOf: result.meals)

            if !result.errors.isEmpty {
                let msg = result.errors.map { $0.localizedDescription }.joined(separator: "\n")
                print("⚠️ Errors for \(result.hall.displayName):\n\(msg)")
                lastError = msg
            }
        }
    }
}
