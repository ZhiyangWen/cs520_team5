//
//  Recipe.swift
//  UMeal
//
//  Created by Shriya Gautam on 4/30/26.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    private let maroon = Color(red: 0.369, green: 0.008, blue: 0.008)

    var body: some View {
        VStack(spacing: 0) {
            Header()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)

                    // Title + favorite
                    HStack {
                        Text(recipe.name)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                            .foregroundColor(recipe.isFavorite ? .yellow : .gray)
                            .font(.title3)
                    }

                    // Nutrition chips
                    HStack(spacing: 12) {
                        NutritionBadge(label: "Protein", value: recipe.protein, unit: "g", color: maroon)
                        NutritionBadge(label: "Fiber", value: recipe.fiber, unit: "g", color: maroon)
                    }

                    Divider()

                    // Ingredients placeholder
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients")
                            .font(.headline)
//                        ForEach(recipe.ingredients, id: \.self) { ingredient in {
//                            
//                            Text(ingredient)
//                                .foregroundColor(.secondary)
//                                .font(.subheadline)
//                        }
//                        }

                    }

                    Divider()

                    // Instructions placeholder
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)
                        Text(recipe.instructions)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(false)
        .background(Color(.systemGroupedBackground))
    }
}

struct NutritionBadge: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(String(format: "%.1f", value))\(unit)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            name: "Orange Chicken",
            isFavorite: true,
            protein: 10.5,
            fiber: 3.2,
            ingredients: ["Chicken", "Orange"],
            instructions: "",
        ))
    }
}
