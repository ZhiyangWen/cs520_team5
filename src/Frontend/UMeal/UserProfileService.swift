//
//  UserProfileService.swift
//  UMeal
//
//  Created by Zhiyang Wen on 5/5/26.
//

import Foundation
import Supabase

struct UserProfileData: Codable {
    let userId: String
    var maxCalories: Int?
    var minProtein: Int?
    var allergies: [String]?
    var preferences: String?
    var fullName: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case maxCalories = "max_calories"
        case minProtein = "min_protein"
        case allergies
        case preferences
        case fullName = "full_name"
    }
}

class UserProfileService {

    // Load profile from Supabase
    static func loadProfile(userId: UUID) async throws -> UserProfileData? {
        let response: [UserProfileData] = try await supabase
            .from("user_profile")
            .select()
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        return response.first
    }

    // Save profile to Supabase
    static func saveProfile(
        userId: UUID,
        maxCalories: Int,
        minProtein: Int,
        allergies: [String]
    ) async throws {
        let profile = UserProfileData(
            userId: userId.uuidString,
            maxCalories: maxCalories,
            minProtein: minProtein,
            allergies: allergies,
            preferences: nil,
            fullName: nil
        )

        try await supabase
            .from("user_profile")
            .upsert(profile, onConflict: "user_id")
            .execute()
    }
}
