//
//  AppearanceSources.swift
//  CyprusPharmacies
//
//  Created by Елена Ким on 05.07.2022.
//

import UIKit

enum AppearanceSource {
    static let buttonCornerRadius: CGFloat = 5
    static let buttonSize: CGSize = CGSize(width: 30, height: 30)
    static let buttonsColor: UIColor = .systemGray6
    static let detailVCPresentHeight: CGFloat = 330
    static let currentLocationButtonBottom: CGFloat = 50
    static let infoPopoverSize: CGSize = CGSize(width: 300, height: 360)
    static let dateLabelSize: CGSize = CGSize(width: 100, height: 30)
    
    static let infoImage: UIImage? = UIImage(systemName: "info.circle", withConfiguration:  UIImage.SymbolConfiguration(pointSize: 16, weight: .light, scale: .large))
    static let pharmacyPin: UIImage? = UIImage(systemName: "cross.circle", withConfiguration:  UIImage.SymbolConfiguration(pointSize: 15, weight: .light, scale: .large))?.withRenderingMode(.alwaysTemplate).colorized(color: .systemGreen)
        
    static let clusterIcon = UIImage(named: "Cluster")
    
}
