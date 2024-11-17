//
//  ContentView.swift
//  Weather
//
//  Created by Sushant Shinde on 15/11/24.
//

import SwiftUI

struct WeatherListView: View {
    @StateObject private var viewModel = WeatherListViewModel()
    private let cities = ["Berlin", "Dallas", "London", "Paris", "Shimla"] // Example cities
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.weatherList, id: \.id) { weather in
                    WeatherRowView(weather: weather) {
                        // Refresh single city
                        Task {
                            await viewModel.refreshWeather(for: weather.cityName)
                        }
                    }
                }
            }
            .navigationTitle("Weather")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh All") {
                        Task {
                            await viewModel.fetchWeather(for: cities)
                        }
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
        }
        .task {
            await viewModel.getWeather()
        }
    }
}


struct WeatherRowView: View {
    let weather: Weather
    let onRefresh: () -> Void
    
    var body: some View {
    
        ZStack(alignment: .bottomLeading) {
            // Background image
            Image(weather.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .cornerRadius(10)
            
            Color.black.opacity(0.3)
                .frame(height: 200)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\(weather.temperature, specifier: "%.1f")°C")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                Text(weather.city)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(weather.country)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
        }
        .overlay(
            // Refresh button in the top-right corner
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            .padding(),
            alignment: .topTrailing
        )
       // .padding(.horizontal)
    }
}

