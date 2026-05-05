//
//  Button.swift
//  
//
//  Created by Shriya Gautam on 4/4/26.
//
import SwiftUI



struct CustomButton: View {
    let text: String

    var body: some View {
        Button(action: {
            print("\(text) button was tapped")
        }) {
            Text(text)
                .foregroundColor(Color.crimson)
                .font(.system(size: 13, weight: .semibold))
                .padding()
                .background(Color.maroon)
                .cornerRadius(10)
        }
    }
}
