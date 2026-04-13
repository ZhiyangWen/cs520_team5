// Services/HTMLMenuParser.swift
// UMeal – CS520 Team 5
// Author: Pornnapin Tangkoskul
//
// Parses raw HTML from umassdining.com/locations-menus/<hall>/<date>
// into an array of DiningMeal objects.
//
// Strategy:
//   1. Primary:  CSS selector parsing (fast, structured)
//   2. Fallback: Text-based parsing (robust to layout changes)
//   3. Malformed nodes are silently skipped (never crash)

import Foundation
import SwiftSoup

enum HTMLMenuParser {

    // MARK: - Public

    /// Entry point. Returns meals parsed from the given HTML string.
    static func parse(html: String, hall: DiningHall, date: String) throws -> [DiningMeal] {
        let doc: Document
        do {
            doc = try SwiftSoup.parse(html)
        } catch {
            throw error
        }

        // Attempt CSS-selector parse first
        var meals = try cssSelectParse(doc: doc, hall: hall, date: date)

        // If CSS approach found nothing, fall back to text-based scan
        if meals.isEmpty {
            meals = textFallbackParse(doc: doc, hall: hall, date: date)
        }

        return meals
    }

    // MARK: - Primary: CSS Selector Parsing

    /// Parses using the known UMass Dining HTML structure.
    ///
    /// Expected DOM (may vary by semester):
    ///   .meal-period-group           ← wraps one meal period (Breakfast/Lunch/Dinner/Late Night)
    ///     h3.meal-period-name        ← period label text
    ///     .meal-station              ← optional station grouping
    ///       h4.station-title         ← station name
    ///       .menu-item-data          ← individual menu item
    ///         .item-title            ← item name
    ///         .diet-icons span       ← dietary flag icons (classes like "icon-vegan")
    ///         .nutrition-info        ← optional nutrition row
    ///
    /// If the selectors return nothing the caller falls back to textFallbackParse.
    private static func cssSelectParse(
        doc: Document,
        hall: DiningHall,
        date: String
    ) throws -> [DiningMeal] {

        var meals: [DiningMeal] = []

        // Try multiple known class name patterns (site may change between semesters)
        let periodSelectors = [
            ".meal-period-group",
            ".menu-period",
            ".views-row",            // Drupal-based fallback
            "[class*='meal-period']"
        ]

        for selector in periodSelectors {
            guard let periodElements = try? doc.select(selector),
                !periodElements.isEmpty()
            else { continue }

            for periodEl in periodElements.array() {
                // Determine meal period from heading text
                let periodText = (try? periodEl.select("h3, h4, .meal-period-name, .period-title")
                    .first()?.text()) ?? ""
                guard let period = MealPeriod.from(rawText: periodText) else { continue }

                // Items may be grouped by station or listed directly
                let stationGroups = (try? periodEl.select(".meal-station, .station-group, .field-group")) ?? Elements()

                if stationGroups.isEmpty() {
                    // No station grouping — parse items directly under period
                    let items = (try? periodEl.select(".menu-item-data, .menu-item, .field-item")) ?? Elements()
                    for item in items.array() {
                        if let meal = parseMealItem(item, hall: hall, date: date,
                                                    period: period, station: nil) {
                            meals.append(meal)
                        }
                    }
                } else {
                    for stationEl in stationGroups.array() {
                        let stationName = (try? stationEl.select("h4, h5, .station-title").first()?.text())
                        let items = (try? stationEl.select(".menu-item-data, .menu-item, .field-item")) ?? Elements()
                        for item in items.array() {
                            if let meal = parseMealItem(item, hall: hall, date: date,
                                                        period: period, station: stationName) {
                                meals.append(meal)
                            }
                        }
                    }
                }
            }
            // If we found meals with this selector, stop trying others
            if !meals.isEmpty { break }
        }

        return meals
    }

    // MARK: - Individual Item Parser

    private static func parseMealItem(
        _ el: Element,
        hall: DiningHall,
        date: String,
        period: MealPeriod,
        station: String?
    ) -> DiningMeal? {
        // Extract item name — try multiple selectors
        let name: String
        if let title = try? el.select(".item-title, .menu-item-name, h5, strong").first()?.text(),
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            name = title.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let text = try? el.text(),
                !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            name = text.components(separatedBy: "\n").first?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? text
        } else {
            return nil   // Skip malformed node
        }

        // Skip obviously garbage nodes
        guard name.count > 1, name.count < 200 else { return nil }

        let flags   = parseDietaryFlags(el)
        let (cal, protein, carbs, fat) = parseNutrition(el)

        return DiningMeal(
            name:         name,
            hall:         hall,
            date:         date,
            mealPeriod:   period,
            station:      station,
            dietaryFlags: flags,
            calories:     cal,
            protein:      protein,
            carbs:        carbs,
            fat:          fat
        )
    }

    // MARK: - Dietary Flag Extraction

    /// Extracts dietary flags from icon classes and text within an item element.
    ///
    /// UMass Dining uses both CSS icon classes (e.g. `icon-vegan`) and
    /// plain text labels (e.g. "vegetarian, vegan") in `<span>` tags.
    private static func parseDietaryFlags(_ el: Element) -> DietaryFlags {
        var flags = DietaryFlags()

        // 1. Check icon classes — primary method
        if let icons = try? el.select("[class*='icon-'], .diet-icon, .dietary-icon, img[alt]") {
            for icon in icons.array() {
                let cls = (try? icon.attr("class")) ?? ""
                let alt = (try? icon.attr("alt")) ?? ""
                let combined = (cls + " " + alt).lowercased()
                applyIconText(combined, to: &flags)
            }
        }

        // 2. Check plain text spans — backup
        if let spans = try? el.select("span, .diet-label") {
            for span in spans.array() {
                let text = ((try? span.text()) ?? "").lowercased()
                applyIconText(text, to: &flags)
            }
        }

        // 3. Extract allergens from "Contains: ..." text
        let fullText = ((try? el.text()) ?? "").lowercased()
        flags.allergens = extractAllergens(from: fullText)

        return flags
    }

    private static func applyIconText(_ text: String, to flags: inout DietaryFlags) {
        if text.contains("vegan")       { flags.isVegan = true; flags.isVegetarian = true }
        if text.contains("vegetarian")  { flags.isVegetarian = true }
        if text.contains("gluten")      { flags.isGlutenFree = true }
        if text.contains("halal")       { flags.isHalal = true }
        if text.contains("kosher")      { flags.isKosher = true }
    }

    /// Parses allergen strings from "Contains: Milk, Wheat/Gluten, Soy" style text.
    private static func extractAllergens(from text: String) -> [String] {
        guard let range = text.range(of: "contains:") else { return [] }
        let after = String(text[range.upperBound...])
        // Take text up to next sentence / newline
        let segment = after.components(separatedBy: CharacterSet(charactersIn: ".\n")).first ?? after
        return segment
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.capitalized }
    }

    // MARK: - Nutrition Parsing

    /// Attempts to extract calorie, protein, carbs, and fat from the item element.
    private static func parseNutrition(_ el: Element) -> (Int?, Double?, Double?, Double?) {
        var calories: Int?    = nil
        var protein:  Double? = nil
        var carbs:    Double? = nil
        var fat:      Double? = nil

        // Try structured nutrition rows first
        if let rows = try? el.select(".nutrition-info, .nutrition-row, .field-nutrition") {
            for row in rows.array() {
                let label = ((try? row.select(".label, th").first()?.text()) ?? "").lowercased()
                let value = ((try? row.select(".value, td").last()?.text()) ?? "")
                    .replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)

                if label.contains("calorie") { calories = Int(value) }
                else if label.contains("protein") { protein = Double(value) }
                else if label.contains("carb") { carbs = Double(value) }
                else if label.contains("fat") { fat = Double(value) }
            }
        }

        // Fallback: scan full text for "Calories #calories#" style placeholders
        // (UMass uses template strings on some pages)
        let fullText = (try? el.text()) ?? ""
        if calories == nil {
            let calPattern = try? NSRegularExpression(pattern: #"(?i)calories?\s*[:\-]?\s*(\d+)"#)
            if let match = calPattern?.firstMatch(in: fullText, range: NSRange(fullText.startIndex..., in: fullText)),
                let range = Range(match.range(at: 1), in: fullText) {
                calories = Int(fullText[range])
            }
        }

        return (calories, protein, carbs, fat)
    }

    // MARK: - Fallback: Text-Based Parsing

    /// Scans all visible text in the document to extract meal items.
    /// Used when CSS selectors produce no results (layout changes, JS-rendered pages).
    ///
    /// Heuristics:
    ///   • Lines that match known meal period names set the current period context.
    ///   • Short text lines (3–100 chars) that aren't navigation/header noise
    ///     are treated as meal item names.
    static func textFallbackParse(
        doc: Document,
        hall: DiningHall,
        date: String
    ) -> [DiningMeal] {

        var meals:         [DiningMeal] = []
        var currentPeriod: MealPeriod?  = nil
        var currentStation: String?     = nil

        // Pull all text-bearing leaf nodes
        guard let body = doc.body() else { return [] }
        let allText = (try? body.text()) ?? ""

        let lines = allText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for line in lines {
            // Check if line is a period heading
            if let period = MealPeriod.from(rawText: line), line.count < 30 {
                currentPeriod = period
                currentStation = nil
                continue
            }
            guard let period = currentPeriod else { continue }

            // Skip navigation / boilerplate text
            if isBoilerplate(line) { continue }

            // Lines all-caps and short ≈ station headers
            if line == line.uppercased() && line.count < 60 && line.count > 3 {
                currentStation = line.capitalized
                continue
            }

            // Candidate meal item
            if line.count >= 3 && line.count <= 120 {
                var flags = DietaryFlags()
                let lower = line.lowercased()
                if lower.contains("vegan")      { flags.isVegan = true; flags.isVegetarian = true }
                if lower.contains("vegetarian") { flags.isVegetarian = true }
                if lower.contains("gluten-free"){ flags.isGlutenFree = true }
                if lower.contains("halal")      { flags.isHalal = true }
                if lower.contains("kosher")     { flags.isKosher = true }
                flags.allergens = extractAllergens(from: lower)

                // Strip trailing dietary text to get clean name
                let cleanName = stripDietaryText(from: line)
                guard !cleanName.isEmpty else { continue }

                let meal = DiningMeal(
                    name:         cleanName,
                    hall:         hall,
                    date:         date,
                    mealPeriod:   period,
                    station:      currentStation,
                    dietaryFlags: flags
                )
                meals.append(meal)
            }
        }
        return meals
    }

    // MARK: - Text Helpers

    /// Known boilerplate phrases that should never be treated as menu items.
    private static let boilerplateKeywords = [
        "skip to", "navigation", "copyright", "university of massachusetts",
        "umass dining", "locations", "allergen", "contact us", "privacy",
        "meal plan", "print menu", "see today", "serving size", "#serving",
        "#calories", "fat cal", "all rights reserved", "cookies", "log in",
        "sign in", "search"
    ]

    private static func isBoilerplate(_ line: String) -> Bool {
        let lower = line.lowercased()
        return boilerplateKeywords.contains { lower.contains($0) }
    }

    /// Strips trailing dietary labels (e.g. "vegetarian, vegan") from item name text.
    private static func stripDietaryText(from text: String) -> String {
        let dietaryTerms = ["vegetarian", "vegan", "gluten-free", "halal", "kosher",
                            "contains:", "dairy-free", "nut-free"]
        var result = text
        for term in dietaryTerms {
            // Remove from the last occurrence of a dietary term onward
            if let range = result.lowercased().range(of: term) {
                let prefix = String(result[..<range.lowerBound])
                    .trimmingCharacters(in: CharacterSet(charactersIn: " ,;|-"))
                if !prefix.isEmpty { result = prefix }
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
