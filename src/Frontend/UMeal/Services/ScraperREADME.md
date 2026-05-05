
# UMass Dining Web Scraper

## Module Overview
The scraper is a critical service that generates live menus for UMeal by extracting data from the official UMass Dining website. This is the source of truth for the "Live UMass Dining Hall Menus" core feature[reference:4].

## Components

The scraping logic is implemented in Swift and consists of several coordinated files:

*   **`UMassDiningScraper.swift`**: The main class that orchestrates the scraping process. It fetches the HTML for relevant pages.
*   **`HTMLMenuParser.swift`**: Contains the core parsing logic. It uses SwiftSoup (a Swift port of jsoup) to navigate the HTML structure and extract menu items, their descriptions, and dietary flags.
*   **`DiningMenuService.swift`**: The facade for the app. ViewModels interact with this service, which in turn uses the scraper and handles caching logic.
*   **`DiningCache.swift`**: Implements a local caching mechanism to store scraped data, ensuring the app remains responsive and functional offline, and reduces the number of network requests.

## Testing
Tests for the scraper are located in `tests/DiningScraperTests.swift`. These tests validate:
-   That all dining hall URLs are correctly identified.
-   The logic for parsing meal periods (e.g., Breakfast, Lunch) from raw text.
-   That the HTML parser can successfully extract meal names, stations, and dietary flags from sample HTML fragments[reference:5].
-   That the system handles malformed or empty HTML nodes gracefully.

## How It Works (Data Flow)
1.  The `DiningMenuService` on the iOS app calls the scraper.
2.  `UMassDiningScraper` fetches the raw HTML from a configured UMass Dining URL.
3.  The HTML content is passed to `HTMLMenuParser`.
4.  `HTMLMenuParser` uses CSS selectors to find specific DOM elements (e.g., menu item containers) and extracts:
    *   Meal Name
    *   Dietary flags (e.g., vegetarian, vegan, halal)
    *   The station where the food is served
    *   Calorie and macronutrient information if available.
5.  The parsed information is transformed into an array of `DiningMeal` objects.
6.  `DiningMenuService` caches the structured data using `DiningCache` and provides it to the UI via ViewModels.

## Development
To make changes to the scraper:
1.  Locate the relevant file in `/src/Frontend/UMeal/Services`.
2.  Edit the parsing logic in `HTMLMenuParser.swift` or the fetching logic in `UMassDiningScraper.swift`.
3.  Run the unit tests in `tests/DiningScraperTests.swift` to ensure your changes haven't broken existing functionality.