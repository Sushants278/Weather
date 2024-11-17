
# Weather App


This project is a weather application that fetches and displays weather data for multiple cities. The app supports both online and offline functionality using Core Data for persistent storage. It employs Swift concurrency for managing asynchronous tasks and ensures a responsive user experience.

## Features

    Fetch weather data online for multiple cities using WeatherRequest.

    Save and retrieve weather data offline with Core Data (WeatherOfflineRequest).

    Handle sort options for weather data (by name or temperature).

    Display loading states and error handling for network issues or data fetch failures.

    Multithreading and concurrency to ensure smooth UI performance.

## Multithreading Approach

The app uses Swift Concurrency (async/await) to handle asynchronous operations like fetching weather data from the network or loading it from Core Data. Here’s how multithreading is managed:

	1.	Network Requests:
	    All network operations are asynchronous to prevent blocking the main thread.
	    withTaskGroup is used for concurrently fetching weather data for multiple cities, optimizing the network fetch process.
	
    2.	Core Data Access:
         Core Data operations (saveWeatherToCoreData, fetchWeatherFromCoreData) are performed on background contexts.
         The context.perform method ensures that Core Data operations are safely executed on the correct thread.
	
    3.	Avoiding Priority Inversion:
        The Reachability.isConnectedToNetwork method was updated to use an asynchronous approach, eliminating semaphore-based blocking, which could lead to priority inversions.
   
    4.	Actor Isolation:
	    The FailedCitiesTracker is an actor that ensures thread-safe tracking of cities for which weather data fetch fails.
	
    5.	UI Updates:
	    Any updates to @Published properties (e.g., weatherList, isLoading) are explicitly performed on the main thread using MainActor.

## Core Data Contexts

To ensure thread safety and efficiency, the app uses the following Core Data contexts:

	1.	Main Context:
	    Used for reading data to populate the UI.
	    Automatically merges changes from the background context (automaticallyMergesChangesFromParent).
	
    2.	Background Context:
	    Used for write-heavy operations like saving new weather data.
	    Ensures write operations do not block the main thread.
	    Configured with NSMergeByPropertyObjectTrumpMergePolicy to handle conflicts during merges.


## Technology Stack

The App is built using the following technologies and libraries:

        Swift: The primary programming language for iOS app development.
        SwiftUI: The user interface framework for building iOS applications.
        Xcode: The integrated development environment (IDE) for iOS app development.
        Core Data: Used for local data storage and offline support.

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

        Model: Represents the data and business logic of the app.
        View: Represents the user interface components.
        ViewModel: Acts as an intermediary between the Model and View, handling data presentation and user interactions.
