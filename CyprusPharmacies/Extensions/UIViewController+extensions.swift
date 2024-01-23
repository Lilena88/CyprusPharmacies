//
//  UIViewController+extensions.swift
//  NightPharmacies
//
//  Created by Елена Ким on 03.08.2022.
//

import UIKit

extension UIViewController {
    func showError(text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
