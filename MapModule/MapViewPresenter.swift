//
//  MapViewPresenter.swift
//  CyprusPharmacies
//
//  Created by Елена Ким on 29.05.2022.
//

import Foundation
import MapKit
import CoreLocation

protocol MapViewOutputProtocol {
    func viewLoaded()
    func fetchPharmaciesList(day: Int, completion: @escaping(Result<(String, [MKAnnotation]), NetworkServiceError>) -> Void)
    func getDirection(mapApp: MapApp)
    func setDestination(_ destination: CLLocationCoordinate2D?)
    func startUpdatingUserLocation()
    func askPermission()
}

enum MapApp {
    case google
    case apple
}

class MapViewPresenter: NSObject, MapViewOutputProtocol {
    private var locationManager: CLLocationManager
    private let networkService: BaseNetworkService<[PharmacyModel]>
    private weak var view: MapViewInputProtocol?
    private var currentLocation: CLLocationCoordinate2D?
    private var destination: CLLocationCoordinate2D?
    
    init(view: MapViewInputProtocol, locationManager: CLLocationManager, networkService: BaseNetworkService<[PharmacyModel]>) {
        self.networkService = networkService
        self.locationManager = locationManager
        self.view = view
    }
    
    func viewLoaded() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    func fetchPharmaciesList(day: Int, completion: @escaping(Result<(String, [MKAnnotation]), NetworkServiceError>) -> Void) {
        guard let url = URL(string: "https://sanstv.ru/pharmacies/data/today.php?offset=\(day)") else { return }
        let task = self.networkService.dataTask(with: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let pharmacyArray):
                    var annotationArray = [MKAnnotation]()
                    for pharmacy  in pharmacyArray {
                        annotationArray.append(pharmacy.getPharmacyAnnotation())
                    }
                    let phramacyDict: (String, [MKAnnotation]) = (pharmacyArray[0].date, annotationArray)
                    completion(.success(phramacyDict))
                }
            }
        }
        task.resume()
    }
    
    func getDirection(mapApp: MapApp) {
        guard let currentLocation = self.currentLocation else {
            let authorizationStatus = self.locationManager.authorizationStatus
            if authorizationStatus == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            } else if authorizationStatus == .denied {
                self.view?.showAlertLocation("Turn on your location", "To get direction we need your current location")
            }
            return
        }
        guard let destination = self.destination else { return }
        
        switch mapApp {
        case .google:
            self.openGoogleMaps(destination: destination, currentLocation: currentLocation)
        case .apple:
            self.openMaps(destination: destination, currentLocation: currentLocation)
        }
        
    }
    
    private func openGoogleMaps(destination: CLLocationCoordinate2D, currentLocation: CLLocationCoordinate2D) {
        guard let url = URL(string: "https://www.google.com/maps/?saddr=\(currentLocation.latitude),\(currentLocation.longitude)&daddr=\(destination.latitude),\(destination.longitude)&directionsmode=driving") else {
            print("Wrong URL")
            return
        }
        
         if UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url)
         } else {
             self.view?.showAlertLocation("Error", "Can't open GoogleMaps")
         }
    }
    
    private func openMaps(destination: CLLocationCoordinate2D, currentLocation: CLLocationCoordinate2D) {
        guard let url = URL(string: "http://maps.apple.com/?saddr=\(currentLocation.latitude),\(currentLocation.longitude)&daddr=\(destination.latitude),\(destination.longitude)") else {
            print("Wrong URL")
            return
        }
        
         if UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url)
         } else {
             self.view?.showAlertLocation("Error", "Can't open Maps")
         }
    }
    
    func setDestination(_ destination: CLLocationCoordinate2D?) {
        self.destination = destination
    }
    
    func startUpdatingUserLocation() {
        if self.locationManager.authorizationStatus == .authorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
            self.view?.setupForAuthorizedWhenInUse()
        } else {
            self.locationManager.stopUpdatingLocation()
            self.view?.changeUserLocationButton()
            self.currentLocation = nil
        }
    }
    
    func askPermission() {
        let authorizationStatus = self.locationManager.authorizationStatus
        if authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if authorizationStatus == .denied {
            self.view?.showAlertLocation("Turn on your location", "To show your current location")
        }
    }
}

extension MapViewPresenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location.coordinate
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError {
            switch clErr.code {
            case .locationUnknown:
                print("location unknown")
            case .denied:
                self.locationManager.stopUpdatingLocation()
                self.locationManager.requestWhenInUseAuthorization()
            default:
                print("other Core Location error")
            }
        } else {
            print("other error:", error.localizedDescription)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch self.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            self.view?.setupForAuthorizedWhenInUse()
        case .denied, .notDetermined, .restricted:
            self.locationManager.stopUpdatingLocation()
            self.view?.changeUserLocationButton()
        default:
            break
        }
    }
}
