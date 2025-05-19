//
//  ContentView.swift
//  HelloDog
//
//  Created by Luc Lisi on 5/19/25.
//

import SwiftUI

struct ContentView: View {
    let x = listDogs()
    let y = getDog(dogBreed: "pinscher")
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(y)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
