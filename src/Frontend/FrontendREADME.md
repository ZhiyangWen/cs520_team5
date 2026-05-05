# UMeal iOS Frontend

## Overview
The UMeal iOS app empowers students at UMass Amherst to make informed dining choices by providing real-time access to dining hall menus, extensive recipe searches, and personal health tracking. The app integrates live menu data, user profiles, and social features to create a comprehensive campus dining companion[reference:0].

## Architecture
This is an iOS native application built using **SwiftUI** and **Swift**. It adopts the **MVVM (Model-View-ViewModel)** architecture.

*   **Views (`/src/Frontend/UMeal/`)**: SwiftUI views for all screens (e.g., `LoginView`, `Home`, `ProfileView`, `RecipeSearchView`).
*   **ViewModels**: (`AuthManager`, `DiningMenuService`): Manage presentation logic and state, interacting with services.
*   **Services (`/Services/`)**: Encapsulate business logic and handle external operations:
    *   `AuthManager`: Manages user authentication state.
    *   `DiningMenuService`: Coordinates the fetching, caching, and parsing of dining data.
    *   `UMassDiningScraper`: Handles the direct scraping logic for UMass dining websites.
    *   `HTMLMenuParser`: Parses raw HTML responses into structured meal objects.
*   **Models**: Swift structs (e.g., `Recipe`, `DiningMeal`) that represent data entities.
