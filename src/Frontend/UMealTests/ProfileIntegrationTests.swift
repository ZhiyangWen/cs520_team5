//
//  ProfileIntegrationTests.swift
//  UMeal
//
//  Created by Zhiyang Wen on 5/8/26.
//

import XCTest
@testable import UMeal

@MainActor
final class ProfileIntegrationTests: XCTestCase {

    var auth: AuthManager!

    override func setUp() async throws {
        auth = AuthManager()
        // Create and login with a test account
        let testEmail = "profile_test_\(UUID().uuidString.lowercased())@umass.edu"
        await auth.signUp(email: testEmail, password: "password123", fullName: "Test User")
    
    }

    override func tearDown() async throws {
        await auth.logout()
        auth = nil
    }

    // Profile Save Tests

    func test_saveProfile_validData_succeeds() async throws {
        guard let userId = auth.userId else {
            XCTFail("Should be logged in")
            return
        }

        do {
            try await UserProfileService.saveProfile(
                userId: userId,
                maxCalories: 2000,
                minProtein: 150,
                allergies: ["Nuts", "Dairy"]
            )
        } catch {
            XCTFail("Save should not throw: \(error)")
        }
    }

    func test_saveProfile_thenLoad_returnsCorrectData() async throws {
        guard let userId = auth.userId else {
            XCTFail("Should be logged in")
            return
        }

        // Save
        let saveStart = Date()
        try await UserProfileService.saveProfile(
            userId: userId,
            maxCalories: 1800,
            minProtein: 100,
            allergies: ["Gluten"]
        )
        print("Profile save time: \(Date().timeIntervalSince(saveStart))s")

        // Load
        let loadStart = Date()
        let profile = try await UserProfileService.loadProfile(userId: userId)
        print("Profile load time: \(Date().timeIntervalSince(loadStart))s")

        XCTAssertNotNil(profile, "Profile should exist after saving")
        XCTAssertEqual(profile?.maxCalories, 1800, "Calories should match saved value")
        XCTAssertEqual(profile?.minProtein, 100, "Protein should match saved value")
        XCTAssertEqual(Set(profile?.allergies ?? []), Set(["Gluten"]))
    }

    func test_saveProfile_updatesExistingData() async throws {
        guard let userId = auth.userId else {
            XCTFail("Should be logged in")
            return
        }

        // Save first time
        try await UserProfileService.saveProfile(
            userId: userId,
            maxCalories: 1500,
            minProtein: 80,
            allergies: ["Soy"]
        )

        // Update with new values
        try await UserProfileService.saveProfile(
            userId: userId,
            maxCalories: 2500,
            minProtein: 200,
            allergies: ["Soy", "Milk"]
        )

        // Load and verify updated values
        let profile = try await UserProfileService.loadProfile(userId: userId)
        XCTAssertEqual(profile?.maxCalories, 2500, "Calories should be updated")
        XCTAssertEqual(profile?.minProtein, 200, "Protein should be updated")
        XCTAssertEqual(profile?.allergies?.count, 2, "Should have 2 allergies")
    }

    // Profile Load Tests

    func test_loadProfile_withValidUser_returnsProfile() async throws {
        guard let userId = auth.userId else {
            XCTFail("Should be logged in")
            return
        }

        let profile = try await UserProfileService.loadProfile(userId: userId)
        XCTAssertNotNil(profile, "Should return profile for logged in user")
    }

    func test_loadProfile_returnsFullName() async throws {
        guard let userId = auth.userId else {
            XCTFail("Should be logged in")
            return
        }

        let profile = try await UserProfileService.loadProfile(userId: userId)
        XCTAssertNotNil(profile?.fullName, "Profile should have full name")
    }

    // Empty Allergies Test

    func test_saveProfile_withEmptyAllergies_succeeds() async throws {
        guard let userId = auth.userId else {
            XCTFail("Should be logged in")
            return
        }

        do {
            try await UserProfileService.saveProfile(
                userId: userId,
                maxCalories: 1000,
                minProtein: 50,
                allergies: []
            )
        } catch {
            XCTFail("Should handle empty allergies: \(error)")
        }

        let profile = try await UserProfileService.loadProfile(userId: userId)
        XCTAssertNotNil(profile, "Profile should still exist with empty allergies")
    }
}
