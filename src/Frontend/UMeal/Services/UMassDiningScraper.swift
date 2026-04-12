// Services/UMassDiningScraper.swift
// UMeal – CS520 Team 5
// Author: Pornnapin Tangkoskul
//
// Dependency: SwiftSoup  (https://github.com/scinfu/SwiftSoup)
// Add to Package.swift or Xcode SPM:
//   .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")

import Foundation
import SwiftSoup

// MARK: - Error Types

enum ScraperError: Error, LocalizedError {
    case invalidURL(String)
    case networkFailure(DiningHall, Error)
    case emptyResponse(DiningHall, String)
    case parseFailure(DiningHall, String, Error)
    case timeout(DiningHall)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let u):               return "Invalid URL: \(u)"
        case .networkFailure(let h, let e):    return "[\(h.displayName)] Network error: \(e.localizedDescription)"
        case .emptyResponse(let h, let url):   return "[\(h.displayName)] Empty HTML from \(url)"
        case .parseFailure(let h, let u, let e): return "[\(h.displayName)] Parse error at \(u): \(e.localizedDescription)"
        case .timeout(let h):                  return "[\(h.displayName)] Request timed out"
        }
    }
}

// MARK: - Scraper Result

/// Outcome per-hall scrape attempt (allows partial failure).
struct HallScrapeResult {
    let hall:   DiningHall
    let meals:  [DiningMeal]
    let errors: [ScraperError]

    var succeeded: Bool { !meals.isEmpty }
}

// MARK: - UMassDiningScraper

/// Fetches and parses dining menus from umassdining.com.
///
/// Design decisions:
///   • async/await throughout — iOS-native concurrency.
///   • All 4 halls scraped in parallel with `TaskGroup`.
///   • Per-date scraping parallelized within each hall (with inter-request delay).
///   • Each hall is isolated: a failure in one does not cancel others.
///   • CSS selector parsing is primary; text-based fallback used when selectors miss.
///   • Cache checked first; full scrape only when stale (every 7–10 days).
actor UMassDiningScraper {

    // MARK: - Configuration

    /// Number of days into the future to scrape (today + 14).
    static let scrapeWindowDays: Int = 14

    /// Delay between requests to the same host (rate-limiting).
    static let interRequestDelayMs: UInt64 = 300

    /// Request timeout in seconds.
    static let timeoutSeconds: Double = 15

    /// Base URL pattern. `<hall>` and `<date>` are replaced at runtime.
    private static let menuURLTemplate =
        "https://umassdining.com/locations-menus/<hall>/<date>"

    // MARK: - Public Entry Point

    /// Main method: returns meals for all halls across a 14-day window.
    /// Loads from cache when fresh; scrapes when stale.
    ///
    /// - Parameter forceRefresh: If true, ignores cache and scrapes immediately.
    /// - Returns: All successfully scraped meals (partial results included).
    func fetchAllHalls(forceRefresh: Bool = false) async -> [HallScrapeResult] {
        var results: [HallScrapeResult] = []

        await withTaskGroup(of: HallScrapeResult.self) { group in
            for hall in DiningHall.allCases {
                group.addTask {
                    // Check cache unless a force refresh is requested
                    if !forceRefresh && !DiningCache.isStale(for: hall) {
                        let cached = DiningCache.load(for: hall)
                        if !cached.isEmpty {
                            print("[\(hall.displayName)] ✅ Loaded \(cached.count) meals from cache.")
                            return HallScrapeResult(hall: hall, meals: cached, errors: [])
                        }
                    }
                    // Cache stale or empty — scrape
                    return await self.scrapeHall(hall)
                }
            }
            for await result in group {
                results.append(result)
            }
        }
        return results
    }

    // MARK: - Per-Hall Scrape

    /// Scrapes all dates in the window for a single hall.
    /// Dates are processed concurrently but with a short delay between requests.
    private func scrapeHall(_ hall: DiningHall) async -> HallScrapeResult {
        let dates = Self.dateRange(days: Self.scrapeWindowDays)
        var allMeals:  [DiningMeal]   = []
        var allErrors: [ScraperError] = []

        // Parallelise per-date scraping within the hall
        await withTaskGroup(of: Result<[DiningMeal], ScraperError>.self) { group in
            for (index, date) in dates.enumerated() {
                group.addTask {
                    // Stagger requests to be polite to the server
                    if index > 0 {
                        try? await Task.sleep(nanoseconds: UInt64(index) * Self.interRequestDelayMs * 1_000_000)
                    }
                    return await self.scrapeHallForDate(hall, date: date)
                }
            }

            for await result in group {
                switch result {
                case .success(let meals):
                    allMeals.append(contentsOf: meals)
                case .failure(let error):
                    allErrors.append(error)
                }
            }
        }

        // Persist to cache even with partial errors
        if !allMeals.isEmpty {
            try? DiningCache.save(meals: allMeals, for: hall)
            print("[\(hall.displayName)] ✅ Scraped \(allMeals.count) meals, \(allErrors.count) errors.")
        } else {
            print("[\(hall.displayName)] ⚠️ No meals scraped. Errors: \(allErrors.count)")
        }

        return HallScrapeResult(hall: hall, meals: allMeals, errors: allErrors)
    }

    // MARK: - Per-Date Scrape

    private func scrapeHallForDate(
        _ hall: DiningHall,
        date: String
    ) async -> Result<[DiningMeal], ScraperError> {

        let urlString = Self.menuURLTemplate
            .replacingOccurrences(of: "<hall>", with: hall.urlSlug)
            .replacingOccurrences(of: "<date>", with: date)

        guard let url = URL(string: urlString) else {
            return .failure(.invalidURL(urlString))
        }

        // Build request with headers to mimic a real browser (User-Agent required)
        var request = URLRequest(url: url, timeoutInterval: Self.timeoutSeconds)
        request.httpMethod = "GET"
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
            forHTTPHeaderField: "User-Agent"
        )
        request.setValue("text/html,application/xhtml+xml", forHTTPHeaderField: "Accept")
        request.setValue("en-US,en;q=0.9",                  forHTTPHeaderField: "Accept-Language")

        // Perform network request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let urlError as URLError where urlError.code == .timedOut {
            return .failure(.timeout(hall))
        } catch {
            return .failure(.networkFailure(hall, error))
        }

        // Validate HTTP status
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            return .failure(.emptyResponse(hall, "HTTP \(http.statusCode) for \(urlString)"))
        }

        guard let html = String(data: data, encoding: .utf8), !html.isEmpty else {
            return .failure(.emptyResponse(hall, urlString))
        }

        // Parse HTML
        do {
            let meals = try HTMLMenuParser.parse(html: html, hall: hall, date: date)
            return .success(meals)
        } catch {
            return .failure(.parseFailure(hall, urlString, error))
        }
    }

    // MARK: - Helpers

    /// Generates an array of "YYYY-MM-DD" date strings for today through `days` days ahead.
    static func dateRange(days: Int) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return (0..<days).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: Date())
                .map { formatter.string(from: $0) }
        }
    }
}
