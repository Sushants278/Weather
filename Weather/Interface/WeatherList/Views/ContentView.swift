//
//  ContentView.swift
//  Weather
//
//  Created by Sushant Shinde on 15/11/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var weatherListVM = WeatherListViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            
            await weatherListVM.fetchWeather(city: "Mumbai")
        }
    }
}

#Preview {
    ContentView()
}
