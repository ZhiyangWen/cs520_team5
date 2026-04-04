//
//  RecipeSearchView.swift
//  Created by Shriya Gautam on 4/2/26.
//


import SwiftUI

struct RecipeSearchView: View {
    
    //fetching database items from supabase
    
//    @State var instruments: [Instrument] = []
//      var body: some View {
//        List(instruments) { instrument in
//          Text(instrument.name)
//        }
//        .overlay {
//          if instruments.isEmpty {
//            ProgressView()
//          }
//        }
//        .task {
//          do {
//            instruments = try await supabase.from("instruments").select().execute().value
//          } catch {
//            dump(error)
//          }
//        }
//      }
//    
    // temporary contents
    var body: some View {
        Header()
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
