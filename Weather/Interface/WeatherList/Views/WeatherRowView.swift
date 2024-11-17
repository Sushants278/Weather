//
//  WeatherRowView.swift
//  Weather
//
//  Created by Sushant Shinde on 17/11/24.
//

import SwiftUI

struct WeatherRowView: View {
    // MARK: - Properties
    let weather: Weather
    let onRefresh: () -> Void

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottomLeading) {
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
