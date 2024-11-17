//
//  ContentView.swift
//  Weather
//
//  Created by Sushant Shinde on 15/11/24.
//

import SwiftUI

struct WeatherListView: View {
    
    /// The view model for the weather list view.
    @StateObject private var viewModel = WeatherListViewModel()

    //MARK: - Body
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.weatherList, id: \.id) { weather in
                    WeatherRowView(weather: weather) {
                        Task {
                            await viewModel.refreshWeather(for: weather.cityName)
                        }
                    }.listRowInsets(EdgeInsets())
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .padding(.vertical, 8)
                     .listRowSeparator(.hidden)
                    }
            }
            .navigationTitle("Weather")
            .toolbar {
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

