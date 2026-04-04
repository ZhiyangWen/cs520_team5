//
//  AddRecipe.swift
//  
//
//  Created by Shriya Gautam on 4/2/26.
//

import SwiftUI

extension Color {
    static let maroon = Color(red: 0.369, green: 0.008, blue: 0.008) // #5E0202
    static let crimson = Color(red: 0.647, green: 0.000, blue: 0.204) // #A50034
    static let Gray      = Color(red: 0.541, green: 0.608, blue: 0.659) // #8A9BA8
}


struct AddRecipe: View {
    var body: some View {
        VStack{
            Header()
            Text("Recipe Title")
            
            Text("Upload Image")
            
            Image(RecipeSearchView.self, "recipe1")
            Text("Recipe Ingredients:")
            
            Text("Recipe Instructions:")
            
            Text("Recipe Tags:")

            
        }
    }
}

#Preview {
    AddRecipe()
}
