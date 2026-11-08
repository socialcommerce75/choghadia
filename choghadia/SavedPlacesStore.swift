import Observation
import SwiftUI

struct SavedPlace: Identifiable, Codable, Equatable {
    var id: String { name + timeZoneID }
    let name: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
    let timeZoneID: String

    static let storageKey = "choghadia.savedPlaces.v1"
    static let selectedPlaceKey = "choghadia.selectedPlace.v1"

    static let cityDirectory: [SavedPlace] = [
        .init(name: "Ahmedabad", subtitle: "Gujarat, India", latitude: 23.0225, longitude: 72.5714, timeZoneID: "Asia/Kolkata"),
        .init(name: "Bengaluru", subtitle: "Karnataka, India", latitude: 12.9716, longitude: 77.5946, timeZoneID: "Asia/Kolkata"),
        .init(name: "Boston", subtitle: "Massachusetts, United States", latitude: 42.3601, longitude: -71.0589, timeZoneID: "America/New_York"),
        .init(name: "Chicago", subtitle: "Illinois, United States", latitude: 41.8781, longitude: -87.6298, timeZoneID: "America/Chicago"),
        .init(name: "Delhi", subtitle: "India", latitude: 28.6139, longitude: 77.2090, timeZoneID: "Asia/Kolkata"),
        .init(name: "London", subtitle: "United Kingdom", latitude: 51.5072, longitude: -0.1276, timeZoneID: "Europe/London"),
        .init(name: "Los Angeles", subtitle: "California, United States", latitude: 34.0522, longitude: -118.2437, timeZoneID: "America/Los_Angeles"),
        .init(name: "Mumbai", subtitle: "Maharashtra, India", latitude: 19.0760, longitude: 72.8777, timeZoneID: "Asia/Kolkata"),
        .init(name: "New York", subtitle: "New York, United States", latitude: 40.7128, longitude: -74.0060, timeZoneID: "America/New_York"),
        .init(name: "Toronto", subtitle: "Ontario, Canada", latitude: 43.6532, longitude: -79.3832, timeZoneID: "America/Toronto")
    ]

    static func load() -> [SavedPlace] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let places = try? JSONDecoder().decode([SavedPlace].self, from: data) else { return [] }
        return places
    }

    static func save(_ places: [SavedPlace]) {
        guard let data = try? JSONEncoder().encode(places) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

/// Single on-device source of truth shared by Today and Settings. Account sync can be added here later.
@MainActor
@Observable
final class SavedPlacesStore {
    static let shared = SavedPlacesStore()

    private(set) var places: [SavedPlace]
    var selectedPlace: SavedPlace? {
        didSet {
            UserDefaults.standard.set(selectedPlace?.id, forKey: SavedPlace.selectedPlaceKey)
        }
    }

    private init() {
        let storedPlaces = SavedPlace.load()
        let storedSelection = UserDefaults.standard.string(forKey: SavedPlace.selectedPlaceKey)
        places = storedPlaces
        selectedPlace = storedPlaces.first(where: { $0.id == storedSelection })
    }

    func select(_ place: SavedPlace, saveIfNeeded: Bool = false) {
        if saveIfNeeded, !places.contains(where: { $0.id == place.id }) {
            places.append(place)
            SavedPlace.save(places)
        }
        selectedPlace = place
    }

    func remove(at offsets: IndexSet) {
        let removedIDs = Set(offsets.map { places[$0].id })
        places.remove(atOffsets: offsets)
        SavedPlace.save(places)
        if let selectedPlace, removedIDs.contains(selectedPlace.id) {
            self.selectedPlace = nil
        }
    }
}
