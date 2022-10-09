//
//  PopoverViewController.swift
//  CyprusPharmacies
//
//  Created by Елена Ким on 05.07.2022.
//

import UIKit
fileprivate enum PopoverAppearance {
    static let infoText: String = "The location of pharmacies on the map was obtained by automatic search on the Google map. We recommend you to clarify the location on the map or check with the pharmacist before the trip.\n\nEach pharmacy on the list will be open from 8 am to 11 pm, including weekends and public holidays.\n\nIn addition, the pharmacist on duty will be available to carry out any prescription after the pharmacy closes - from 11 pm to 8 am the next day. You can call the listed numbers to contact a pharmacist to fulfil a prescription.\n\nIf a duty pharmacist does not have the medicines necessary to fulfil the prescription, he/she must write on the prescription the words “Medicines that are not available” and sign, indicating the day and time.\n"
    
    static let popoverButtonTitle: NSAttributedString? = NSAttributedString(
        string: "For more information",
        attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                     NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
    )
}

class PopoverViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
        }()
    private let scrollStackViewContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .justified
        return label
    }()
    private let moreButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(PopoverAppearance.popoverButtonTitle, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupScrollView()
        self.infoLabel.text = PopoverAppearance.infoText
        self.moreButton.addTarget(self, action: #selector(goToWebsite), for: .touchUpInside)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if traitCollection.userInterfaceStyle == .dark {
            self.infoLabel.textColor = .white
        }
    }
    
    @objc func goToWebsite() {
        guard let url = URL(string: "https://www.moh.gov.cy/moh/phs/phs.nsf/All/091BC51661367EE1C225857B002F972D?OpenDocument") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            self.showError(text: "Can't open website")
        }
    }
    
    private func setupScrollView() {
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollStackViewContainer)
        self.scrollView.anchor(
            top: self.view.topAnchor,
            leading: self.view.leadingAnchor,
            bottom: self.view.bottomAnchor,
            trailing: self.view.trailingAnchor,
            padding: .init(top: 20, left: 10, bottom: 20, right: 10)
        )
        
        self.scrollStackViewContainer.anchor(
            top: self.scrollView.topAnchor,
            leading: self.scrollView.leadingAnchor,
            bottom: self.scrollView.bottomAnchor,
            trailing: self.scrollView.trailingAnchor
        )
        self.scrollStackViewContainer.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        self.configureContainerView()
    }
    private func configureContainerView() {
        self.scrollStackViewContainer.addArrangedSubview(self.infoLabel)
        self.scrollStackViewContainer.addArrangedSubview(self.moreButton)
    }
}
