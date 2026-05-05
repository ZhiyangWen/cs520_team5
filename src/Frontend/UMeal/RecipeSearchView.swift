import SwiftUI
internal import PostgREST
import Supabase

struct Recipe: Identifiable, Decodable {
    let meal_id: UUID
    let meal_name: String
    let calories: Int
    let protein: Double
    let fiber: Double
    let instructions: String?
    let ingredients: String
    let recipe_link: String?

    var id: UUID { meal_id }
}


struct RecipeSearchView: View {

    private let maroon = Color(red: 0.369, green: 0.008, blue: 0.008)

    // mock data for now, TODO: replace with Supabase fetch
//    let recipes: [Recipe] = [
//        Recipe(name: "Orange Chicken", isFavorite: true, protein: 10.5, fiber: 3.2, ingredients: ["Chicken, Flour, Seasonings, Broccoli"], instructions:""),
//        Recipe(name: "Breakfast Burrito", isFavorite: true, protein: 20.0, fiber: 10.2,ingredients: ["Flour Tortillas, Egg, Black Beans, Cheddar Cheese"], instructions:""),
//        Recipe(name: "Vegetable Lasagna", isFavorite: false, protein: 15.0, fiber: 2.0, ingredients: ["Chicken, Flour, Seasonings, Broccoli"], instructions:""),
//        Recipe(name: "Tofu Stir-Fry", isFavorite: false, protein: 10.9, fiber: 3.5, ingredients: ["Chicken, Flour, Seasonings, Broccoli"], instructions:""),
//    ]

    @State private var searchText: String = ""
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false

        
    var filtered: [Recipe] {
        searchText.isEmpty ? recipes : recipes.filter {
            $0.meal_name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
             VStack(spacing: 12) {
                   Header()
                        
                   HStack {
                        Image(systemName: "line.3.horizontal").foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "magnifyingglass").foregroundColor(maroon)
                   }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemBackground))
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)

                    if isLoading {
                            ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
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
                                                                        .foregroundColor(maroon)
                                                                    Text(recipe.meal_name)        // <-- updated
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
                                    }
                                    .background(Color(.systemGroupedBackground))
                                    .task {
                                        await fetchRecipes()       // fires when view appears
                                    }
                                }
                            }

                            func fetchRecipes() async {
                                isLoading = true
                                defer { isLoading = false }
                                do {
                                    recipes = try await supabase
                                        .from("meals_list")
                                        .select()
                                        .execute()
                                        .value
                                } catch {
                                    print("Failed to fetch recipes: \(error)")
                                }
                            }
                        }


#Preview {
    RecipeSearchView()
}
