
import Foundation
import CoreLocation
// will be used later


// MARK: Use only hour and minute components. day compenents might be wrong in some contexts.
// MARK: This is not pricise one. just use it to handle features of UI modifying from day and night.
class SunriseSunsetViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var sunrise: Date?
    @Published var sunset: Date?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

    }

    func updateSunriseSunsetTimes(for coordinate: CLLocationCoordinate2D) {
        let timeZone = Calendar.current.timeZone
        
        // Usage example:
        let calculator = SolarCalculator(latitude: coordinate.latitude, longitude: coordinate.longitude, timeZone: timeZone)
        let (sunrise, sunset) = calculator.calculateSunriseSunset(for: Date())
        
        DispatchQueue.main.async {
            self.sunrise = sunrise
            self.sunset = sunset
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        updateSunriseSunsetTimes(for: location.coordinate)
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}


