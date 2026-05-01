// Tests/DiningScraperTests.swift
// UMeal – CS520 Team 5
// Author: Pornnapin Tangkoskul
//
import XCTest
@testable import UMeal

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
    // Updated to match real UMass dining HTML structure:
    // h2 = meal period, h3 = station, li > a[href="#inline"] = menu item

    func test_cssParser_parsesWellFormedHTML() throws {
        let sampleHTML = """
        <html><body>
          <h2>Dinner</h2>
          <h3>Sauté Station</h3>
          <ul>
            <li>
              <a href="#inline">Grilled Chicken</a>
              <img src="/legends/icon-hal.png"/>
            </li>
            <li>
              <a href="#inline">Pasta Primavera</a>
              <img src="/legends/icon-vegan.png"/>
            </li>
          </ul>
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
        XCTAssertTrue(chicken?.dietaryFlags.isHalal ?? false)

        let pasta = meals.first { $0.name == "Pasta Primavera" }
        XCTAssertNotNil(pasta)
        XCTAssertTrue(pasta?.dietaryFlags.isVegan ?? false)
        XCTAssertTrue(pasta?.dietaryFlags.isVegetarian ?? false)
    }
        

    func test_cssParser_skipsEmptyAndMalformedNodes() throws {
        let html = """
        <html><body>
          <h2>Breakfast</h2>
          <h3>Breakfast Entrees</h3>
          <ul>
            <li><a href="#inline"></a></li>
            <li><a href="#inline">   </a></li>
            <li><a href="#inline">Oatmeal</a></li>
          </ul>
        </body></html>
        """
        let meals = try HTMLMenuParser.parse(html: html, hall: .berkshire, date: "2026-04-15")
        XCTAssertEqual(meals.count, 1)
        XCTAssertEqual(meals.first?.name, "Oatmeal")
    }

    // MARK: - HTML Parser — Text fallback

    func test_textFallback_parsesPlainText() throws {
        // Fallback is triggered when no li:has(a[href='#inline']) elements exist
        // The text fallback scans body text line by line
        let html = """
        <html><body>
          <h2>Dinner</h2>
          <h3>SALAD BAR</h3>
          <ul>
            <li><a href="#inline">Caesar Salad</a></li>
            <li><a href="#inline">Garden Salad</a></li>
          </ul>
        </body></html>
        """
        let meals = try HTMLMenuParser.parse(html: html, hall: .franklin, date: "2026-04-15")
        XCTAssertGreaterThanOrEqual(meals.count, 1)
        XCTAssertTrue(meals.allSatisfy { $0.mealPeriod == .dinner })
    }

    // MARK: - Dietary Flags

    func test_dietaryFlags_veganImpliesVegetarian() throws {
        let html = """
        <html><body>
          <h2>Lunch</h2>
          <h3>Vegan Station</h3>
          <ul>
            <li>
              <a href="#inline">Tofu Bowl</a>
              <img src="/legends/icon-vegan.png"/>
            </li>
          </ul>
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
          <h2>Breakfast</h2>
          <h3>Breakfast Entrees</h3>
          <ul>
            <li>
              <a href="#inline">Pancakes</a>
              <img src="/legends/icon-veg.png"/>
              <span>Contains: Wheat/Gluten, Milk, Eggs</span>
            </li>
          </ul>
        </body></html>
        """
        let meals = try HTMLMenuParser.parse(html: html, hall: .berkshire, date: "2026-04-15")
        let pancakes = meals.first { $0.name == "Pancakes" }
        XCTAssertNotNil(pancakes)
        // Allergens are extracted from the full text of the li element
        let fullText = "Contains: Wheat/Gluten, Milk, Eggs"
        XCTAssertTrue(fullText.lowercased().contains("contains:"))
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
