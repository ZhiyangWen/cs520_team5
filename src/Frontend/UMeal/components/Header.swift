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
