// Tests/DiningScraperTests.swift
// UMeal – CS520 Team 5
// Author: Pornnapin Tangkoskul

import XCTest
@testable import UMeal  // adjust to your actual module name
// import SwiftSoup      // already imported transitively

final class DiningScraperTests: XCTestCase {

    // MARK: - DiningHall

    func test_allHalls_covered() {
        XCTAssertEqual(DiningHall.allCases.count, 4)
        let slugs = DiningHall.allCases.map(\.urlSlug)
        XCTAssert(slugs.contains("berkshire"))
        XCTAssert(slugs.contains("worcester"))
        XCTAssert(slugs.contains("franklin"))
        XCTAssert(slugs.contains("hampshire"))
    }

    // MARK: - MealPeriod

    func test_mealPeriod_fromText() {
        XCTAssertEqual(MealPeriod.from(rawText: "Breakfast"),        .breakfast)
        XCTAssertEqual(MealPeriod.from(rawText: "LUNCH"),            .lunch)
        XCTAssertEqual(MealPeriod.from(rawText: "Dinner Service"),   .dinner)
        XCTAssertEqual(MealPeriod.from(rawText: "Late Night Snack"), .lateNight)
        XCTAssertNil(MealPeriod.from(rawText: "Random Text"))
    }

    // MARK: - Date Range

    func test_dateRange_count() {
        let range = UMassDiningScraper.dateRange(days: 14)
        XCTAssertEqual(range.count, 14)
    }

    func test_dateRange_format() {
        let range = UMassDiningScraper.dateRange(days: 3)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        for dateStr in range {
            XCTAssertNotNil(formatter.date(from: dateStr),
                            "Expected 'yyyy-MM-dd' format, got: \(dateStr)")
        }
    }

    func test_dateRange_startIsToday() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        let range  = UMassDiningScraper.dateRange(days: 5)
        XCTAssertEqual(range.first, today)
    }

    // MARK: - HTML Parser — CSS selector path

    func test_cssParser_parsesWellFormedHTML() throws {
        let sampleHTML = """
        <html><body>
          <div class="meal-period-group">
            <h3 class="meal-period-name">Dinner</h3>
            <div class="meal-station">
              <h4 class="station-title">Sauté Station</h4>
              <div class="menu-item-data">
                <span class="item-title">Grilled Chicken</span>
                <span class="icon-halal">halal</span>
              </div>
              <div class="menu-item-data">
                <span class="item-title">Pasta Primavera</span>
                <span>vegetarian, vegan</span>
                <span>Contains: Wheat/Gluten, Milk</span>
              </div>
            </div>
          </div>
        </body></html>
        """

        let meals = try HTMLMenuParser.parse(html: sampleHTML,
                                            hall: .worcester,
                                            date: "2026-04-15")
        XCTAssertEqual(meals.count, 2)

        let chicken = meals.first { $0.name == "Grilled Chicken" }
        XCTAssertNotNil(chicken)
        XCTAssertEqual(chicken?.hall,       .worcester)
        XCTAssertEqual(chicken?.mealPeriod, .dinner)
        XCTAssertEqual(chicken?.station,    "Sauté Station")
        XCTAssertTrue(chicken?.dietaryFlags.isHalal ?? false)

        let pasta = meals.first { $0.name == "Pasta Primavera" }
        XCTAssertNotNil(pasta)
        XCTAssertTrue(pasta?.dietaryFlags.isVegan ?? false)
        XCTAssertTrue(pasta?.dietaryFlags.isVegetarian ?? false)
        XCTAssertFalse(pasta?.dietaryFlags.allergens.isEmpty ?? true)
    }

    func test_cssParser_skipsEmptyAndMalformedNodes() throws {
        let html = """
        <html><body>
          <div class="meal-period-group">
            <h3>Breakfast</h3>
            <div class="menu-item-data"><span class="item-title"></span></div>
            <div class="menu-item-data"><span class="item-title">   </span></div>
            <div class="menu-item-data"><span class="item-title">Oatmeal</span></div>
          </div>
        </body></html>
        """
        let meals = try HTMLMenuParser.parse(html: html, hall: .berkshire, date: "2026-04-15")
        XCTAssertEqual(meals.count, 1)
        XCTAssertEqual(meals.first?.name, "Oatmeal")
    }

    // MARK: - HTML Parser — Text fallback

    func test_textFallback_parsesPlainText() throws {
        // Simulate a page where CSS selectors would find nothing useful
        let html = """
        <html><body>
          <p>Dinner</p>
          <p>SALAD BAR</p>
          <p>Caesar Salad vegetarian Contains: Milk, Wheat/Gluten</p>
          <p>Garden Salad vegetarian, vegan</p>
          <p>Skip to navigation</p>
        </body></html>
        """
        // Since CSS selectors won't find .meal-period-group, fallback is invoked
        let meals = try HTMLMenuParser.parse(html: html, hall: .franklin, date: "2026-04-15")
        // We at minimum get Caesar + Garden (navigation skipped)
        XCTAssertGreaterThanOrEqual(meals.count, 1)
        XCTAssertTrue(meals.allSatisfy { $0.mealPeriod == .dinner })
    }

    // MARK: - Dietary Flags

    func test_dietaryFlags_veganImpliesVegetarian() throws {
        let html = """
        <html><body>
          <div class="meal-period-group">
            <h3>Lunch</h3>
            <div class="menu-item-data">
              <span class="item-title">Tofu Bowl</span>
              <span class="icon-vegan">vegan</span>
            </div>
          </div>
        </body></html>
        """
        let meals = try HTMLMenuParser.parse(html: html, hall: .hampshire, date: "2026-04-15")
        let tofu = meals.first { $0.name == "Tofu Bowl" }
        XCTAssertTrue(tofu?.dietaryFlags.isVegan       ?? false, "Should be vegan")
        XCTAssertTrue(tofu?.dietaryFlags.isVegetarian  ?? false, "Vegan implies vegetarian")
    }

    func test_allergenExtraction() throws {
        let html = """
        <html><body>
          <div class="meal-period-group">
            <h3>Breakfast</h3>
            <div class="menu-item-data">
              <span class="item-title">Pancakes</span>
              <span>vegetarian Contains: Wheat/Gluten, Milk, Eggs</span>
            </div>
          </div>
        </body></html>
        """
        let meals = try HTMLMenuParser.parse(html: html, hall: .berkshire, date: "2026-04-15")
        let pancakes = meals.first { $0.name == "Pancakes" }
        XCTAssertNotNil(pancakes)
        let allergens = pancakes?.dietaryFlags.allergens ?? []
        XCTAssertTrue(allergens.contains(where: { $0.contains("Gluten") }),
                      "Expected Wheat/Gluten allergen, got: \(allergens)")
    }

    // MARK: - Cache

    func test_cache_saveAndLoad() throws {
        let meal = DiningMeal(
            name: "Test Meal",
            hall: .berkshire,
            date: "2026-04-15",
            mealPeriod: .dinner
        )
        try DiningCache.save(meals: [meal], for: .berkshire)
        let loaded = DiningCache.load(for: .berkshire)
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.name, "Test Meal")

        DiningCache.clearAll()
    }

    func test_cache_isStale_whenNoCacheExists() {
        DiningCache.clearAll()
        XCTAssertTrue(DiningCache.isStale(for: .worcester))
    }

    func test_cache_isFreshAfterSave() throws {
        let meal = DiningMeal(name: "Fresh", hall: .worcester,
                              date: "2026-04-15", mealPeriod: .lunch)
        try DiningCache.save(meals: [meal], for: .worcester)
        XCTAssertFalse(DiningCache.isStale(for: .worcester))
        DiningCache.clearAll()
    }

    // MARK: - DiningMenuService filtering

    @MainActor
    func test_filteredMeals_byDietaryFlag() {
        let service = DiningMenuService()
        let vegan = DiningMeal(name: "Salad", hall: .berkshire, date: "2026-04-15",
                              mealPeriod: .lunch,
                              dietaryFlags: DietaryFlags(isVegan: true, isVegetarian: true))
        let nonVegan = DiningMeal(name: "Chicken", hall: .berkshire, date: "2026-04-15",
                                  mealPeriod: .lunch)
        service.meals = [vegan, nonVegan]

        let results = service.filteredMeals(veganOnly: true)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Salad")
    }
}
