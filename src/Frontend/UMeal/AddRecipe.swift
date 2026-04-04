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
            TextField("", text: $title)
                .padding(12)
                .frame(height: 60)
                .background(Color(.systemBackground))
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
            Text("Upload Image")
            
            Image(RecipeSearchView.self, "recipe1")
            Text("Recipe Ingredients:")
            
            Text("Recipe Instructions:")
            TextField("", text: $instructions)
                .padding(12)
                .frame(height: 60)
                .background(Color(.systemBackground))
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color(.systemGray4), lineWidth: 2)
                )
            
            Text("Recipe Tags:")

            Button(action: {
                //submit recipe info to database
              print("\(text) button was tapped")
            }) {
              Text("Submit Recipe")
                .foregroundColor(Color.crimson)
                .font(.system(size: 13 ,weight: .semibold))
                .padding()
                .background(Color.maroon)
                .cornerRadius(10)
            }
            
            Button(action: {
            //go back to home page
              Home()
            }) {
              Text("Back")
                .foregroundColor(Color.crimson)
                .font(.system(size: 13 ,weight: .semibold))
                .padding()
                .background(Color.Gray)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    AddRecipe()
}
