//
//  AddRecipeTests.swift
//  UMeal
//
//  Created by Shriya Gautam on 5/9/26.
//

// AddRecipeIntegrationTests.swift
// Place in your app's test target

import XCTest
import SwiftUI
@testable import UMeal  


// MARK: - Test Helpers

/// Exposes isFormValid for unit testing without needing a live view.
struct AddRecipeTestWrapper {
    var title: String
    var instructions: String

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !instructions.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

/// Mirrors the mutable ingredient state so we can test list operations
/// without spinning up a full SwiftUI view.
struct AddRecipeStateWrapper {
    var ingredients: [AddRecipe.Ingredient] = [AddRecipe.Ingredient()]

    mutating func addIngredient() {
        ingredients.append(AddRecipe.Ingredient())
    }
}

/// Extract this from AddRecipe's "Post Recipe" button action —
/// it keeps the view thin and makes the payload fully testable.
enum AddRecipePayloadBuilder {
    static func build(
        title: String,
        instructions: String,
        ingredients: [AddRecipe.Ingredient]
    ) -> [String: Any] {
        let ingredientString = ingredients
            .map { "\($0.name): \($0.quantity)" }
            .joined(separator: ", ")

        return [
            "meal_name":    title,
            "instructions": instructions,
            "ingredients":  ingredientString,
        ]
    }
}

@MainActor
final class AddRecipeIntegrationTests: XCTestCase {

    // MARK: - Helpers

    /// Boots the view and returns the hosting controller so we can
    /// poke at @State via the public interface (buttons / text fields).
    private func makeHostingController() -> UIHostingController<AddRecipe> {
        let vc = UIHostingController(rootView: AddRecipe())
        vc.loadViewIfNeeded()
        // Give SwiftUI one run-loop tick to finish layout
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        return vc
    }

    // MARK: - Initial State

    func test_initialState_formIsInvalid() {
        // A freshly opened AddRecipe should NOT pass validation
        // because title and instructions are empty.
       let view = AddRecipe()
        XCTAssertFalse(view.isFormValid,
                       "Form should be invalid when title and instructions are empty")
    }

    // MARK: - Form Validation

    func test_validation_titleOnlyIsInvalid() {
        // Filling title alone is not enough
        let view = AddRecipeTestWrapper(title: "Pasta", instructions: "")
        XCTAssertFalse(view.isFormValid)
    }

    func test_validation_instructionsOnlyIsInvalid() {
        let view = AddRecipeTestWrapper(title: "", instructions: "Boil water")
        XCTAssertFalse(view.isFormValid)
    }

    func test_validation_whitespaceOnlyTitleIsInvalid() {
        let view = AddRecipeTestWrapper(title: "   ", instructions: "Boil water")
        XCTAssertFalse(view.isFormValid,
                       "Whitespace-only title must not pass validation")
    }

    func test_validation_whitespaceOnlyInstructionsIsInvalid() {
        let view = AddRecipeTestWrapper(title: "Pasta", instructions: "\n\t  ")
        XCTAssertFalse(view.isFormValid,
                       "Whitespace-only instructions must not pass validation")
    }

    func test_validation_bothFieldsFilledIsValid() {
        let view = AddRecipeTestWrapper(title: "Pasta", instructions: "Boil water")
        XCTAssertTrue(view.isFormValid)
    }

    func test_validation_longTitleAndInstructionsIsValid() {
        let title = String(repeating: "A", count: 500)
        let instructions = String(repeating: "Step 1. ", count: 200)
        let view = AddRecipeTestWrapper(title: title, instructions: instructions)
        XCTAssertTrue(view.isFormValid)
    }

    // MARK: - Ingredient Model

    func test_ingredient_hasUniqueIDs() {
        let a = AddRecipe.Ingredient()
        let b = AddRecipe.Ingredient()
        XCTAssertNotEqual(a.id, b.id)
    }

    func test_ingredient_defaultsToEmptyStrings() {
        let ingredient = AddRecipe.Ingredient()
        XCTAssertEqual(ingredient.name, "")
        XCTAssertEqual(ingredient.quantity, "")
    }

    func test_ingredient_storesNameAndQuantity() {
        var ingredient = AddRecipe.Ingredient()
        ingredient.name = "Flour"
        ingredient.quantity = "2 cups"
        XCTAssertEqual(ingredient.name, "Flour")
        XCTAssertEqual(ingredient.quantity, "2 cups")
    }

    // MARK: - Ingredient List Mutation (via wrapper)

    func test_addingIngredient_increasesCount() {
        var wrapper = AddRecipeStateWrapper()
        XCTAssertEqual(wrapper.ingredients.count, 1, "Should start with one blank ingredient")
        wrapper.addIngredient()
        XCTAssertEqual(wrapper.ingredients.count, 2)
    }

    func test_addingMultipleIngredients() {
        var wrapper = AddRecipeStateWrapper()
        for _ in 0..<9 { wrapper.addIngredient() }
        XCTAssertEqual(wrapper.ingredients.count, 10)
    }

    func test_ingredientNamesAreMutable() {
        var wrapper = AddRecipeStateWrapper()
        wrapper.ingredients[0].name = "Sugar"
        XCTAssertEqual(wrapper.ingredients[0].name, "Sugar")
    }

    // MARK: - Supabase Payload Shape

    /// Verifies that the helper that builds the DB payload produces
    /// the expected keys and values before any network call is made.
    func test_supabasePayload_containsExpectedFields() {
        let title = "Avocado Toast"
        let instructions = "Toast bread. Spread avocado."
        let ingredients = [
            AddRecipe.Ingredient(name: "Bread", quantity: "2 slices"),
            AddRecipe.Ingredient(name: "Avocado", quantity: "1"),
        ]

        let payload = AddRecipePayloadBuilder.build(
            title: title,
            instructions: instructions,
            ingredients: ingredients
        )

        XCTAssertEqual(payload["meal_name"] as? String, title)
        XCTAssertEqual(payload["instructions"] as? String, instructions)

        // Ingredients should be serialised to a non-empty string
        let ingredientsValue = payload["ingredients"] as? String
        XCTAssertNotNil(ingredientsValue)
        XCTAssertTrue(ingredientsValue!.contains("Bread"),
                      "Payload ingredients should mention Bread")
        XCTAssertTrue(ingredientsValue!.contains("Avocado"),
                      "Payload ingredients should mention Avocado")
    }

    func test_supabasePayload_emptyIngredients() {
        let payload = AddRecipePayloadBuilder.build(
            title: "Plain",
            instructions: "Do nothing",
            ingredients: []
        )
        // Should still have the key, just empty / blank
        XCTAssertNotNil(payload["ingredients"])
    }
}
