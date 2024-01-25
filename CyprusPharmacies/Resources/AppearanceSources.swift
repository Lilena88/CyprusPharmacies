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
    static let pharmacyPin: UIImage? = UIImage(named: "pin")
    
    static let lightGreen: UIColor = UIColor(red: 0.46, green: 0.83, blue: 0.51, alpha: 1)
}
