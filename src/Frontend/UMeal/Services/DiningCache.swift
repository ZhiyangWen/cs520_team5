// Services/DiningCache.swift
// UMeal – CS520 Team 5
// Author: Pornnapin Tangkoskul

import Foundation

/// Manages on-device caching of scraped dining menus.
///
/// Strategy (satisfies CS 520 rate-limiting requirement):
///   • Full 14-day scrape runs every `staleDays` days (default 7).
///   • App launch loads cached data; scraper fires only when stale.
///   • Partial hall failures are tolerated — cached data for other halls stays intact.
final class DiningCache {

    // MARK: - Configuration

    /// Number of days before cached data is considered stale.
    static let staleDays: Int = 7

    // MARK: - Private helpers

    private static let cacheDirectory: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory,
                                                in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("UMealDiningCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir,
                                                withIntermediateDirectories: true)
        return dir
    }()

    private static func cacheFile(for hall: DiningHall) -> URL {
        cacheDirectory.appendingPathComponent("\(hall.rawValue)_menu.json")
    }

    private static func metaFile(for hall: DiningHall) -> URL {
        cacheDirectory.appendingPathComponent("\(hall.rawValue)_meta.json")
    }

    // MARK: - Public API

    /// Persists scraped meals to disk for a given hall.
    static func save(meals: [DiningMeal], for hall: DiningHall) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(meals)
        try data.write(to: cacheFile(for: hall), options: .atomic)

        // Record the timestamp of this scrape.
        let meta = ["lastScraped": ISO8601DateFormatter().string(from: Date())]
        let metaData = try JSONSerialization.data(withJSONObject: meta)
        try metaData.write(to: metaFile(for: hall), options: .atomic)
    }

    /// Loads cached meals for a hall. Returns empty array if cache is missing.
    static func load(for hall: DiningHall) -> [DiningMeal] {
        guard let data = try? Data(contentsOf: cacheFile(for: hall)) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([DiningMeal].self, from: data)) ?? []
    }

    /// Returns `true` if the cache for a hall is missing or older than `staleDays`.
    static func isStale(for hall: DiningHall) -> Bool {
        guard
            let data = try? Data(contentsOf: metaFile(for: hall)),
            let meta = try? JSONSerialization.jsonObject(with: data) as? [String: String],
            let dateStr = meta["lastScraped"],
            let date = ISO8601DateFormatter().date(from: dateStr)
        else {
            return true   // No cache → treat as stale
        }
        let daysSince = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 999
        return daysSince >= staleDays
    }

    /// Removes all cached files (useful for testing / forced refresh).
    static func clearAll() {
        for hall in DiningHall.allCases {
            try? FileManager.default.removeItem(at: cacheFile(for: hall))
            try? FileManager.default.removeItem(at: metaFile(for: hall))
        }
    }

    /// Convenience: load all halls from cache.
    static func loadAll() -> [DiningMeal] {
        DiningHall.allCases.flatMap { load(for: $0) }
    }
}
