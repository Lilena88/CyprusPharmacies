//
//  PharmacyAnnotationView.swift
//  NightPharmacies
//
//  Created by Elena Kim on 1/23/24.
//

import MapKit

class PharmacyAnnotationView: MKAnnotationView {
    
    static let reuseID = "pharmacyID"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.clusteringIdentifier = "pharmacyClusterID"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        image = AppearanceSource.pharmacyPin

    }
    
    private func createPin() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        return renderer.image { _ in
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 30, height: 30)).fill()
          
        }
    }
    
}
