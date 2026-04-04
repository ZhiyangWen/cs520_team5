//
//  Home.swift
//
//  Created by Shriya Gautam on 4/4/26.
//



import SwiftUI

struct Home: View {
    let username: String
    
    var body: some View {
        VStack{
            Header()
            Text("Welcome back {username}")
            
            
        }
    }
}

#Preview {
    Home()
}
