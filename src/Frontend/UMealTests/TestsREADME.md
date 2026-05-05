
# UMeal Testing Strategy

## Testing Overview
The UMeal project aims for a high-quality, robust codebase through a comprehensive testing strategy. Tests are located in multiple places: `/src/Frontend/UMealTests/` for most tests, and `/tests/` for the primary web scraping tests.

## Test Types & Coverage

### 1. Unit Tests (`/src/Frontend/UMealTests/`)
These tests verify the smallest units of code, such as individual functions and methods, in isolation.
*   **What to test:** Core logic in ViewModels (like `DiningMenuService` filtering), helper functions (e.g., date formatting), and model initializers.

### 2. Integration Tests (`/src/Frontend/UMealTests/`)
These tests ensure different modules or services work correctly together.
*   **What to test:** The interaction between `AuthManager` and a real (or mocked) Supabase client, or the data flow from `DiningMenuService` to the cache and back.

### 3. UI Tests (`/src/Frontend/UMealUITests/`)
Built using Xcode's XCTest framework for UI automation, these tests simulate user interactions to verify the app's flow.
*   **What to test:** Login and sign-up flows, navigating between tabs (e.g., Home, Search, Profile), and basic end-to-end user journeys.
*   **How to run:** In Xcode, select the `UMealUITests` target and press `Cmd + U`.

### 4. Web Scraper Tests (`/tests/DiningScraperTests.swift`)
This specific test suite is dedicated to ensuring the reliability of the UMass dining menu scraper.
*   **What it tests:**
    *   **Parsing Logic:** Uses sample HTML snippets to validate that `HTMLMenuParser.swift` correctly extracts meal information (name, station, dietary flags)[reference:7].
    *   **Resilience:** Tests that the parser correctly skips over malformed or empty HTML nodes without crashing[reference:8].
    *   **Configuration:** Checks that all expected dining halls are mapped and their URL slugs are valid[reference:9].

## Running the Tests

1.  **Open the project** in Xcode (`UMeal.xcodeproj`).
2.  **Select a test target** from the scheme selector (e.g., `UMealTests`, `UMealUITests`).
3.  **Run all tests** by pressing `Cmd + U` or by navigating to `Product > Test`.
4.  **Run a specific test suite** by clicking the diamond icon next to the test class or a specific test function in the source code editor.

## Test Data & Mocks
-   **Mock Data**: When writing tests, avoid making real network calls. Create mock objects or structs to simulate successful and failed responses from external services.
-   **Test HTML**: The scraper tests rely on static, local HTML strings to verify parsing logic, ensuring tests are fast, repeatable, and not dependent on a live network connection.