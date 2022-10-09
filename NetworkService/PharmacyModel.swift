//
//  PharmacyModel.swift
//  CyprusPharmacies
//
//  Created by Елена Ким on 10.04.2022.
//

import Foundation
import MapKit

struct PharmacyModel: Decodable {
    let date: String
    let name: String
    let address: String
    let originalAddress: String
    let pharmacyPhone: String
    let homePhone: String
    let lat: Double
    let lng: Double
    
    func getPharmacyAnnotation() -> MKAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
        let annotation = PharmacyAnnotation(
            coordinate: coordinate,
            name: self.name,
            address: self.address,
            originalAddress: self.originalAddress,
            pharmacyPhone: self.pharmacyPhone,
            homePhone: self.homePhone)
        return annotation
    }
}

class PharmacyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    let address: String
    let originalAddress: String
    let pharmacyPhone: String
    let homePhone: String
    
    init(coordinate: CLLocationCoordinate2D, name: String, address: String, originalAddress: String, pharmacyPhone: String, homePhone: String) {
        self.coordinate = coordinate
        self.title = name
        self.address = address
        self.originalAddress = originalAddress
        self.pharmacyPhone = pharmacyPhone
        self.homePhone = homePhone
    }
}
