import SwiftUI

struct Recipe: Identifiable {
    let id = UUID()
    let name: String
    let isFavorite: Bool
    let protein: Double
    let fiber: Double
    let ingredients: [String]
    let instructions: String
}


struct RecipeSearchView: View {
    @State private var searchText: String = ""

    private let maroon = Color(red: 0.369, green: 0.008, blue: 0.008)

    // mock data for now, TODO: replace with Supabase fetch
    let recipes: [Recipe] = [
        Recipe(name: "Orange Chicken", isFavorite: true, protein: 10.5, fiber: 3.2, ingredients: ["Chicken, Flour, Seasonings, Broccoli"], instructions:""),
        Recipe(name: "Breakfast Burrito", isFavorite: true, protein: 20.0, fiber: 10.2,ingredients: ["Flour Tortillas, Egg, Black Beans, Cheddar Cheese"], instructions:""),
        Recipe(name: "Vegetable Lasagna", isFavorite: false, protein: 15.0, fiber: 2.0, ingredients: ["Chicken, Flour, Seasonings, Broccoli"], instructions:""),
        Recipe(name: "Tofu Stir-Fry", isFavorite: false, protein: 10.9, fiber: 3.5, ingredients: ["Chicken, Flour, Seasonings, Broccoli"], instructions:""),
    ]

    var filtered: [Recipe] {
        searchText.isEmpty ? recipes : recipes.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
                    VStack(spacing: 12) {
                        Header()

                        // Search bar (unchanged)
                        HStack {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(maroon)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)

                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filtered) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        HStack(spacing: 0) {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .frame(width: 160, height: 110)
                                                .padding(8)

                                            Spacer()

                                            VStack(alignment: .trailing, spacing: 40) {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(recipe.isFavorite ? .yellow : maroon)
                                                Text(recipe.name)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 20, weight: .semibold))
                                                    .multilineTextAlignment(.trailing)
                                            }
                                            .padding(.trailing, 12)
                                            .padding(.vertical, 12)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .background(maroon)
                                        .cornerRadius(16)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
}

#Preview {
    RecipeSearchView()
}
