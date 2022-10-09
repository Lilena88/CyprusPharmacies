//
//  DetailsViewController.swift
//  CyprusPharmacies
//
//  Created by Елена Ким on 12.06.2022.
//

import Foundation
import UIKit

fileprivate enum DetailsAppearance {
    static let pinImage: UIImage? = UIImage(systemName: "mappin.and.ellipse")
    static let businessPhoneImage: UIImage? = UIImage(systemName: "phone")
    static let homePhoneImage: UIImage? = UIImage(systemName: "house")
    static let directionButtonTitle: String = "Get direction"
    static let mainViewCornerRadius: CGFloat = 20
    static let directionButtonCornerRadius: CGFloat = 10
    static let iconsColor: UIColor = .systemBlue
}

class DetailsViewController: UIViewController {
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(PharmacyNameCell.self, forCellReuseIdentifier: "PharmacyNameCell")
        table.isScrollEnabled = false
        return table
    }()
    
    private var pharmacyModel: PharmacyAnnotation?
    var setDirection: (()->())?
    var hideSelfView: (()->())?
    private var copyText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        self.view.layer.cornerRadius = DetailsAppearance.mainViewCornerRadius
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = DetailsAppearance.mainViewCornerRadius
        blurView.layer.masksToBounds = true
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.addSubview(self.tableView)
        self.tableView.frame = self.view.bounds
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.layer.cornerRadius = DetailsAppearance.mainViewCornerRadius
        self.tableView.backgroundColor = .clear
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(hideSelf))
        swipe.direction = .down
        self.view.addGestureRecognizer(swipe)
    }
    
    // MARK: - Copy text actions
    @objc func tapEdit(_ recognizer: UILongPressGestureRecognizer)  {
        guard recognizer.state == .began,
              let senderView = recognizer.view,
              let superView = recognizer.view?.superview
        else { return }
        senderView.becomeFirstResponder()
        let menuController = UIMenuController.shared
        guard !menuController.isMenuVisible else { return  }
        menuController.menuItems = [
            UIMenuItem(
                title: "Copy address",
                action: #selector(handleCopyAction(_:))
            )
        ]
        menuController.showMenu(from: superView, rect: senderView.frame)
        let tapLocation = recognizer.location(in: self.tableView)
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) {
                guard let conf = tappedCell.contentConfiguration as? UIListContentConfiguration, let address = conf.secondaryText else { return }
                self.copyText = address
            }
        }
    }
    
    @objc func handleCopyAction(_ controller: UIMenuController) {
        if let copyText = self.copyText {
            UIPasteboard.general.string = copyText
        }
    }
    
    // MARK: - Setting data from parent vc
    func setPharmacy(data: PharmacyAnnotation) {
        self.pharmacyModel = data
        self.tableView.reloadData()
    }

    @objc func hideSelf() {
        if let hideSelfView = self.hideSelfView {
            hideSelfView()
        }
    }
    
    @objc func setDirectionTapped() {
        if let setDirection = self.setDirection {
            setDirection()
        }
    }

}

// MARK: - UITableViewDataSource
extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.pharmacyModel else { return UITableViewCell() }
        let blurEffect = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        switch indexPath.row {
        case 0:
            let cell = self.pharmacyNameCell(tableView: tableView, indexPath: indexPath, backView: blurView, model: model)
            return cell
        case 1:
            let cell = self.phoneCell(
                tableView: tableView,
                indexPath: indexPath,
                backView: blurView,
                image: DetailsAppearance.businessPhoneImage,
                text: model.pharmacyPhone
            )
            return cell
        case 2:
            let cell = self.phoneCell(
                tableView: tableView,
                indexPath: indexPath,
                backView: blurView,
                image: DetailsAppearance.homePhoneImage,
                text: model.homePhone
            )
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        footerView.backgroundColor = .clear
        
        let button = UIButton()
        button.addTarget(self, action: #selector(setDirectionTapped), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.setTitle(DetailsAppearance.directionButtonTitle, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = DetailsAppearance.directionButtonCornerRadius
        footerView.addSubview(button)
        button.frame.size = CGSize(width: footerView.frame.width - 40, height: 50)
        button.frame.origin = CGPoint(x: (footerView.frame.width - button.frame.width) / 2,
                                      y: (footerView.frame.height - button.frame.height) / 2)
        return footerView
    }
    
    private func pharmacyNameCell(tableView: UITableView, indexPath: IndexPath, backView: UIView, model: PharmacyAnnotation) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PharmacyNameCell", for: indexPath) as? PharmacyNameCell else { fatalError("wrong cell")}
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.selectedBackgroundView = backView
        var content = cell.defaultContentConfiguration()
        content.imageProperties.tintColor = DetailsAppearance.iconsColor
        content.image = DetailsAppearance.pinImage
        content.text = model.title
        content.secondaryText = model.address + "" + "\n\(model.originalAddress)"
        cell.contentConfiguration = content
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(tapEdit(_ :)))
        longPressGR.minimumPressDuration = 0.3 // how long before menu pops up
        cell.addGestureRecognizer(longPressGR)
        return cell
    }
    private func phoneCell(tableView: UITableView, indexPath: IndexPath, backView: UIView, image: UIImage?, text: String) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        cell.backgroundColor = .clear
        cell.selectedBackgroundView = backView
        var content = cell.defaultContentConfiguration()
        content.imageProperties.tintColor = DetailsAppearance.iconsColor
        content.image = image
        content.text = text
        cell.contentConfiguration = content
        return cell
    }

}

// MARK: - UITableViewDelegate
extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 150
        case 1: return 50
        case 2: return 50
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var phoneNumber: String?
        if indexPath.row == 1 {
            phoneNumber = self.pharmacyModel?.pharmacyPhone
        } else if indexPath.row == 2 {
            phoneNumber = self.pharmacyModel?.homePhone
        }
        if var number = phoneNumber {
            number.remove(at: number.startIndex)
            if let callUrl = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(callUrl) {
                UIApplication.shared.open(callUrl)
            }
        }
    }

}

// MARK: - PharmacyNameCell
class PharmacyNameCell: UITableViewCell {
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
