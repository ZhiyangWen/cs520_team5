//
//  AddRecipe.swift
//  
//
//  Created by Shriya Gautam on 4/2/26.
//

import SwiftUI




struct AddRecipe: View {
    @State private var title: String = ""
    @State private var instructions: String = ""
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
            
            //Image(RecipeSearchView.self, "recipe1")
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
              print("\(title) button was tapped")
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
              Home(username: "")
            }) {
              Text("Back")
                .foregroundColor(Color.crimson)
                .font(.system(size: 13 ,weight: .semibold))
                .padding()
                .background(Color.gray)
                .cornerRadius(10)
            }
        }
    }
}

#Preview {
    AddRecipe()
}
