//
//  RecipeSearchView.swift
//  Created by Shriya Gautam on 4/2/26.
//


import SwiftUI

struct RecipeSearchView: View {
    var body: some View {
        NavigationLink(destination: Home()){
            Text("Home")
        }
        Text("Search Recipes:")
        VStack{
           
            Text("Recipe 1")
            Image(RecipeSearchView.self, "recipe1")
            Text("Recipe 2")
            
            Text("Recipe 3")

        }
    }
}


#Preview {
    RecipeSearchView()
}
