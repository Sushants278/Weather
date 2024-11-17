//
//  ContentView.swift
//  Weather
//
//  Created by Sushant Shinde on 15/11/24.
//

import SwiftUI

struct WeatherListView: View {
    @StateObject private var viewModel = WeatherListViewModel()

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
                // Refresh All Button with Icon
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.fetchInitialWeatherData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }

                // Sort Menu
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(action: {
                            viewModel.sortOption = .byName
                        }) {
                            Label("Sort by Name", systemImage: viewModel.sortOption == .byName ? "checkmark" : "")
                        }
                        Button(action: {
                            viewModel.sortOption = .byTemperature
                        }) {
                            Label("Sort by Temperature", systemImage: viewModel.sortOption == .byTemperature ? "checkmark" : "")
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                        .ignoresSafeArea()
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("Retry") {
                    Task {
                        await viewModel.fetchInitialWeatherData()
                    }
                }
                Button("Dismiss") {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error. Try pulling to refresh or clicking 'Refresh All.'")
            }
            .refreshable {
                await viewModel.fetchInitialWeatherData()
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

            VStack(alignment: .leading, spacing: 5) {
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
            ZStack {
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
            }
            .padding(),
            alignment: .topTrailing
        )
    }
}
