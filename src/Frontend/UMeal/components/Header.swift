//
//  Header.swift
//  
//
//  Created by Shriya Gautam on 4/4/26.
//

// Colors


import SwiftUI

struct Header: View {
    var body: some View {
        VStack(spacing: 10) {
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
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(Color(red: 0.369, green: 0.008, blue: 0.008))
    }
}
