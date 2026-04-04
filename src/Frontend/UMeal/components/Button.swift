//
//  Button.swift
//  
//
//  Created by Shriya Gautam on 4/4/26.
//

extension Color {
    static let maroon = Color(red: 0.369, green: 0.008, blue: 0.008) // #5E0202
    static let crimson = Color(red: 0.647, green: 0.000, blue: 0.204) // #A50034
    static let Gray      = Color(red: 0.541, green: 0.608, blue: 0.659) // #8A9BA8
}


struct Button: View {
  let text: String

  var body: some View {
    Button(action: {
      print("\(text) button was tapped")
    }) {
      Text(text)
        .foregroundColor(Color.crimson)
        .font(.system(size: 13 ,weight: .semibold))
        .padding()
        .background(Color.maroon)
        .cornerRadius(10)
    }
  }
}
