//
//  SearchRecipeTests.swift
//  UMeal
//
//  Created by Shriya Gautam on 5/9/26.
//


import XCTest
import SwiftUI
@testable import UMeal

final class RecipeSearchViewIntegrationTests: XCTestCase {


    struct RecipeSearchWrapper {
        var recipes: [Recipe]
        var searchText: String

        var filtered: [Recipe] {
            searchText.isEmpty ? recipes : recipes.filter {
                $0.meal_name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func makeRecipe(
        name: String = "Test Recipe",
        calories: Int = 400,
        protein: Double = 20.0,
        fiber: Double = 5.0,
        ingredients: String = "Flour, Water",
        instructions: String? = nil,
        recipeLink: String? = nil
    ) -> Recipe {
        Recipe(
            meal_id: UUID(),
            meal_name: name,
            calories: calories,
            protein: protein,
            fiber: fiber,
            instructions: instructions,
            ingredients: ingredients,
            recipe_link: recipeLink
        )
    }

    // MARK: - Recipe Model

    func test_recipe_idMatchesMealId() {
        let recipe = makeRecipe()
        XCTAssertEqual(recipe.id, recipe.meal_id)
    }

    func test_recipe_optionalFieldsCanBeNil() {
        let recipe = makeRecipe(instructions: nil, recipeLink: nil)
        XCTAssertNil(recipe.instructions)
        XCTAssertNil(recipe.recipe_link)
    }

    func test_recipe_optionalFieldsCanBeSet() {
        let recipe = makeRecipe(
            instructions: "Boil water",
            recipeLink: "https://example.com"
        )
        XCTAssertEqual(recipe.instructions, "Boil water")
        XCTAssertEqual(recipe.recipe_link, "https://example.com")
    }

    func test_recipe_decodable_fromValidJSON() throws {
        let json = """
        {
            "meal_id": "550e8400-e29b-41d4-a716-446655440000",
            "meal_name": "Pasta",
            "calories": 600,
            "protein": 18.5,
            "fiber": 3.0,
            "instructions": "Boil and serve",
            "ingredients": "Pasta, Sauce",
            "recipe_link": null
        }
        """.data(using: .utf8)!

        let recipe = try JSONDecoder().decode(Recipe.self, from: json)
        XCTAssertEqual(recipe.meal_name, "Pasta")
        XCTAssertEqual(recipe.calories, 600)
        XCTAssertEqual(recipe.protein, 18.5)
        XCTAssertEqual(recipe.fiber, 3.0)
        XCTAssertEqual(recipe.instructions, "Boil and serve")
        XCTAssertNil(recipe.recipe_link)
    }

    func test_recipe_decodable_failsWithMissingRequiredField() {
        // meal_name is missing — should throw
        let json = """
        {
            "meal_id": "550e8400-e29b-41d4-a716-446655440000",
            "calories": 600,
            "protein": 18.5,
            "fiber": 3.0,
            "ingredients": "Pasta, Sauce"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(Recipe.self, from: json))
    }

    // MARK: - Filter Logic

    func test_filter_emptySearchReturnsAll() {
        let recipes = [makeRecipe(name: "Pasta"), makeRecipe(name: "Salad")]
        let wrapper = RecipeSearchWrapper(recipes: recipes, searchText: "")
        XCTAssertEqual(wrapper.filtered.count, 2)
    }

    func test_filter_matchingQueryReturnsSubset() {
        let recipes = [makeRecipe(name: "Pasta"), makeRecipe(name: "Salad")]
        let wrapper = RecipeSearchWrapper(recipes: recipes, searchText: "Pasta")
        XCTAssertEqual(wrapper.filtered.count, 1)
        XCTAssertEqual(wrapper.filtered.first?.meal_name, "Pasta")
    }

    func test_filter_isCaseInsensitive() {
        let recipes = [makeRecipe(name: "Avocado Toast")]
        let wrapper = RecipeSearchWrapper(recipes: recipes, searchText: "avocado")
        XCTAssertEqual(wrapper.filtered.count, 1)
    }

    func test_filter_partialMatchWorks() {
        let recipes = [makeRecipe(name: "Chicken Stir Fry"), makeRecipe(name: "Tofu Stir Fry")]
        let wrapper = RecipeSearchWrapper(recipes: recipes, searchText: "Stir")
        XCTAssertEqual(wrapper.filtered.count, 2)
    }

    func test_filter_noMatchReturnsEmpty() {
        let recipes = [makeRecipe(name: "Pasta"), makeRecipe(name: "Salad")]
        let wrapper = RecipeSearchWrapper(recipes: recipes, searchText: "Sushi")
        XCTAssertEqual(wrapper.filtered.count, 0)
    }

    func test_filter_emptyRecipeListReturnsEmpty() {
        let wrapper = RecipeSearchWrapper(recipes: [], searchText: "Pasta")
        XCTAssertEqual(wrapper.filtered.count, 0)
    }

    func test_filter_whitespaceQueryMatchesNothing() {
        // A blank search string counts as empty → returns all
        let recipes = [makeRecipe(name: "Pasta")]
        let wrapper = RecipeSearchWrapper(recipes: recipes, searchText: "")
        XCTAssertEqual(wrapper.filtered.count, 1)
    }

    func test_filter_specialCharactersInQuery() {
        let recipes = [makeRecipe(name: "Macaroni & Cheese")]
        let wrapper = RecipeSearchWrapper(recipes: recipes, searchText: "&")
        XCTAssertEqual(wrapper.filtered.count, 1)
    }

    // MARK: - Uniqueness

    func test_recipes_haveUniqueIDs() {
        let recipes = (0..<5).map { makeRecipe(name: "Recipe \($0)") }
        let ids = Set(recipes.map { $0.id })
        XCTAssertEqual(ids.count, recipes.count, "All recipe IDs must be unique")
    }
}
