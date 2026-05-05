# UMeal Authentication Service

## Auth Manager Overview
The `AuthManager` class is the central hub for all authentication and user profile logic in the UMeal iOS app. It leverages the Supabase Swift SDK to interact with Supabase Auth and the project's database, ensuring a seamless and secure user experience.

## Core Functions

The `AuthManager` class, located in `src/Frontend/UMeal/AuthManager.swift`, provides the following core functionalities[reference:6]:

*   **User Sign-Up (`signUp`)**: Creates a new user in Supabase Auth. Upon successful creation, it automatically creates a corresponding profile in the `user_profile` table, initializing it with the user's basic information.
*   **User Login (`login`)**: Authenticates an existing user with their email and password. It then fetches the user's profile data (e.g., `full_name`) from the `user_profile` table to keep the local session state up-to-date.
*   **Session Check (`checkSession`)**: Called when the app launches to check if there is an active Supabase session. If a valid session exists, it restores the user's logged-in state and re-fetches their profile data.
*   **User Logout (`logout`)**: Signs the user out of the Supabase session and clears all local authentication-related state.

## State Management

The `AuthManager` is an `ObservableObject` designed for use with SwiftUI views. It publishes the following key properties, which views can observe and react to:

*   `@Published var isLoggedIn`: A boolean indicating the authentication status.
*   `@Published var username`: The authenticated user's email address.
*   `@Published var fullName`: The user's full name from the profile.
*   `@Published var errorMessage`: A string used to display authentication errors to the user.
*   `@Published var isLoading`: A boolean to show/hide loading indicators during network operations.

## Supabase Integration

The manager directly uses Supabase's SQL API to interact with the database. For instance, after signing up, it makes an `insert` call to the `user_profile` table:

```swift
try await supabase
    .from("user_profile")
    .insert(["user_id": userId.uuidString, "full_name": fullName])
    .execute()