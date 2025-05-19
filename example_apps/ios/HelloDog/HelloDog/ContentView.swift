//
//  ContentView.swift
//  HelloDog
//
//  Created by Luc Lisi on 5/19/25.
//

import SwiftUI

struct ContentView: View {
    let x = listDogs()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
