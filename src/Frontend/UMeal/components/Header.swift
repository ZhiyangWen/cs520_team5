//
//  Header.swift
//  
//
//  Created by Shriya Gautam on 4/4/26.
//

// Colors
extension Color {
    static let maroon = Color(red: 0.369, green: 0.008, blue: 0.008) // #5E0202
    static let crimson = Color(red: 0.647, green: 0.000, blue: 0.204) // #A50034
    static let Gray      = Color(red: 0.541, green: 0.608, blue: 0.659) // #8A9BA8
}

import SwiftUI

struct Header: View {
    var body: some View {
        VStack(spacing: 12) {
            // Our logo
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 100, height: 100)
                // Imported from figma
                Image("Vector")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
            }

            Text("UMeal")
                .font(.system(size: 35, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.bottom, 40)
        .background(Color.maroon)
    }
}
