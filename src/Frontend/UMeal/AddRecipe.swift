//
//  AddRecipe.swift
//  
//
//  Created by Shriya Gautam on 4/2/26.
//
import SwiftUI

struct AddRecipe: View {
    struct Ingredient: Identifiable {
        let id = UUID()
        var name: String = ""
        var quantity: String = ""
    }

    @State private var title: String = ""
    @State private var instructions: String = ""
    @State private var ingredients: [Ingredient] = [Ingredient()]
    @Environment(\.dismiss) var dismiss
 
    private let maroon = Color(red: 0.369, green: 0.008, blue: 0.008)
    private let crimson = Color(red: 0.647, green: 0.000, blue: 0.204)

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !instructions.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 15) {
            Header()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {

                    // Recipe Name
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recipe Name:")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        TextField("", text: $title)
                            .padding(12)
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(22)
                    }

                    // Ingredients
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredients:")
                            .foregroundColor(.white)
                            .font(.subheadline)

                        ForEach($ingredients) { $ingredient in
                            HStack(spacing: 10) {
                                TextField("Ingredient Name", text: $ingredient.name)
                                    .padding(12)
                                    .frame(height: 44)
                                    .background(Color.white)
                                    .cornerRadius(22)

                                TextField("Quantity", text: $ingredient.quantity)
                                    .padding(12)
                                    .frame(height: 44)
                                    .background(Color.white)
                                    .cornerRadius(22)
                                    .frame(maxWidth: 120)
                            }
                        }

                        Button(action: {
                            ingredients.append(Ingredient())
                        }) {
                            Image(systemName: "plus.rectangle")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(22)
                        }
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Instructions:")
                            .foregroundColor(.white)
                            .font(.subheadline)

                        TextEditor(text: $instructions)
                            .frame(minHeight: 180)
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .scrollContentBackground(.hidden)
                    }
                }
                .padding()
            }
            .background(maroon)
            .cornerRadius(16)
            .padding(.horizontal)

            // Post Button
            Button(action: {
                // TODO: save recipe
                dismiss()
            }) {
                Text("Post Recipe")
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(crimson)
                    .cornerRadius(30)
            }
            .disabled(!isFormValid)
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    AddRecipe()
}

