//
//  ViewController.swift
//  CyprusPharmacies
//
//  Created by Елена Ким on 10.04.2022.
//

import UIKit
import MapKit

protocol MapViewInputProtocol: AnyObject {
    func showAlertLocation(_ title: String, _ message: String)
    func centerMap(coordinate: CLLocationCoordinate2D)
    func setupForAuthorizedWhenInUse()
    func showError(text: String)
    func changeUserLocationButton()
}

class MapViewController: UIViewController, MapViewInputProtocol, UIGestureRecognizerDelegate {
    private var presenter: MapViewOutputProtocol!
    private let detailVC = DetailsViewController()
    @IBOutlet weak var mapView: MKMapView!
    private let infoButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = AppearanceSource.infoImage
        button.configuration = config
        return button
    }()
    private var userLocationButton = MKUserTrackingButton()
    private let disabledButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private var currentDay: Int = 0 {
        didSet {
            if self.currentDay == 0 {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
            } else {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            }
        }
    }
    
    // MARK: - LifeCycle methods
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let locationManager = CLLocationManager()
        let networkService = BaseNetworkService<[PharmacyModel]>()
        self.presenter = MapViewPresenter(view: self, locationManager: locationManager, networkService: networkService)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.blurView)
        self.view.addSubview(self.userLocationButton)
        self.view.addSubview(self.infoButton)
        self.view.addSubview(self.disabledButton)
        
        self.addChildVC()
        self.presenter.viewLoaded()
        self.registerAnnotationViewClasses()
        self.detailVC.hideSelfView = self.hideDetailsVC
        self.setupButtons()
        self.setupMapView()
        self.setupNavigationItem()
        self.fetchPharmacies(currentDay: self.currentDay)
        self.addGestureRecognizers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActiveApp), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.blurView.frame = CGRect(x: 0, y: 0,
                                width: self.view.frame.width,
                                height: self.view.safeAreaInsets.top)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc func resignActive() {
        self.dismiss(animated: true)
    }
    
    // MARK: - Get pharmacies list method
    private func fetchPharmacies(currentDay: Int) {
        self.presenter.fetchPharmaciesList(day: self.currentDay) { [weak self] result in
            guard let self = self else { return }
            switch result{
            case .failure(let error):
                self.showError(text: "Loading data error \(error)")
            case .success((let date, let annotations)):
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
                self.title = date
            }
        }
    }
    
    private func registerAnnotationViewClasses() {
        mapView.register(PharmacyAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }
    
    // MARK: - Setup mapView and location
    private func setupMapView() {
        self.mapView.delegate = self
        let initialLocation = CLLocation(latitude: 35.027522, longitude: 33.239529)
        self.mapView.mapType = .standard
        self.mapView.centerToLocation(initialLocation, regionRadius: 200000)
    }
    
    // MARK: - Setup views
    private func setupButtons() {
        self.userLocationButton.mapView = self.mapView
        self.userLocationButton.translatesAutoresizingMaskIntoConstraints = false
        self.userLocationButton.anchor(
            top: nil,
            leading: nil,
            bottom: self.detailVC.view.topAnchor,
            trailing: self.view.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 50, right: 10),
            size: AppearanceSource.buttonSize
        )
        self.userLocationButton.backgroundColor = AppearanceSource.buttonsColor
        self.userLocationButton.layer.cornerRadius = AppearanceSource.buttonCornerRadius
        self.addShadow(to: self.userLocationButton)
        self.disabledButton.anchor(
            top: nil,
            leading: nil,
            bottom: self.detailVC.view.topAnchor,
            trailing: self.view.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 50, right: 10),
            size: AppearanceSource.buttonSize
        )
        self.disabledButton.addTarget(self, action: #selector(disabledButtonTapped), for: .touchUpInside)
        
        self.infoButton.translatesAutoresizingMaskIntoConstraints = false
        self.infoButton.anchor(
            top: nil,
            leading: nil,
            bottom: self.userLocationButton.topAnchor,
            trailing: self.view.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 20, right: 10),
            size: AppearanceSource.buttonSize
        )
        self.infoButton.addTarget(self, action: #selector(showInfo(sender:)), for: .touchUpInside)
        self.infoButton.layer.cornerRadius = AppearanceSource.buttonCornerRadius
        self.infoButton.backgroundColor = AppearanceSource.buttonsColor
        self.addShadow(to: self.infoButton)
    }
    
    private func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.5
    }
    
    private func setupNavigationItem() {
        let leftButton = UIBarButtonItem(title: "Prev Day", style: .done, target: self, action: #selector(previousDate))
        self.navigationItem.setLeftBarButton(leftButton, animated: true)
        let rightButton = UIBarButtonItem(title: "Next Day", style: .done, target: self, action: #selector(nextDate))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    private func addGestureRecognizers() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.zoomMap(_:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
  
    // MARK: - Detail view controller methods
    private func addChildVC() {
        self.view.addSubview(self.detailVC.view)
        self.addChild(self.detailVC)
        self.detailVC.didMove(toParent: self)
        self.detailVC.view.frame.origin = CGPoint(x: 0, y: self.view.frame.maxY)
    }
    
    private func presentDetailVC() {
        UIView.animate(withDuration: 0.3) {
            self.detailVC.view.frame.origin.y = self.view.frame.maxY - AppearanceSource.detailVCPresentHeight - self.view.safeAreaInsets.bottom
            self.userLocationButton.frame.origin.y = self.detailVC.view.frame.origin.y - self.userLocationButton.frame.height - AppearanceSource.currentLocationButtonBottom
        }
    }
    
    private func hideDetailsVC() {
        UIView.animate(withDuration: 0.3) {
            self.detailVC.view.frame.origin.y = self.view.frame.maxY
            self.userLocationButton.frame.origin.y = self.view.frame.maxY - self.userLocationButton.frame.height - AppearanceSource.currentLocationButtonBottom - self.view.safeAreaInsets.bottom
        }
        self.mapView.deselectAnnotation(self.mapView.selectedAnnotations.first, animated: true)
    }
    
    // MARK: - Get direction
    private func getDirectionTapped() {
        let alert = UIAlertController(title: "Choose", message: "Map to get direction", preferredStyle: .actionSheet)
        
        let maps = UIAlertAction(title: "Apple Maps", style: .default) { [weak self] _ in
            self?.presenter.getDirection(mapApp: .apple)
        }
        alert.addAction(maps)
        
        let googleMaps = UIAlertAction(title: "Google Maps", style: .default) { [weak self] _ in
            self?.presenter.getDirection(mapApp: .google)
        }
        alert.addAction(googleMaps)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Objc methods
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        mapView.isZoomEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.isZoomEnabled = true
        }
    }
    
    @objc func zoomMap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.mapView)
        let coordinate = self.mapView.convert(tapLocation, toCoordinateFrom: self.mapView)
        zoom(to: coordinate)
    }
    private func zoom(to coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: self.mapView.region.span.latitudeDelta / 4,
                                    longitudeDelta: self.mapView.region.span.longitudeDelta / 4)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
    @objc func showInfo(sender: UIButton) {
        let buttonFrame = sender.frame
        let popoverContentController = PopoverViewController()
        popoverContentController.modalPresentationStyle = .popover
        popoverContentController.preferredContentSize = AppearanceSource.infoPopoverSize
        if let popoverPresentationController = popoverContentController.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .down
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = self
            
            present(popoverContentController, animated: true, completion: nil)
        }
    }
    
    @objc func becomeActiveApp() {
        self.presenter.startUpdatingUserLocation()
        self.fetchPharmacies(currentDay: self.currentDay)
    }
    
    @objc func disabledButtonTapped() {
        self.presenter.askPermission()
    }
    
    @objc func previousDate() {
        self.currentDay -= 1
        self.fetchPharmacies(currentDay: self.currentDay)
    }
    
    @objc func nextDate() {
        self.currentDay += 1
        self.fetchPharmacies(currentDay: self.currentDay)
    }
    
    // MARK: - MapViewInputProtocol
    func setupForAuthorizedWhenInUse() {
        self.mapView.showsUserLocation = true
        self.disabledButton.isHidden = true
        self.userLocationButton.tintColor = .systemBlue
        self.userLocationButton.isUserInteractionEnabled = true
    }
    
    func changeUserLocationButton() {
        self.userLocationButton.tintColor = .gray
        self.disabledButton.isHidden = false
        self.userLocationButton.isUserInteractionEnabled = false
    }
    
    func centerMap(coordinate: CLLocationCoordinate2D) {
        self.mapView.setCenter(coordinate, animated: true)
    }
    
    func showAlertLocation(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        let cancelAction = UIAlertAction(title: "No, thanks", style: .cancel)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let view = view as? ClusterAnnotationView, let coordinate = view.annotation?.coordinate {
            zoom(to: coordinate)
        } else {
            if let annotation = view.annotation as? PharmacyAnnotation {
                self.detailVC.setPharmacy(data: annotation)
                self.presenter.setDestination(annotation.coordinate)
                self.detailVC.setDirection = self.getDirectionTapped
                self.presentDetailVC()

                guard var center = view.annotation?.coordinate else { return }
                let lat = center.latitude - mapView.region.span.latitudeDelta * 0.15
                center.latitude = lat
                let region = MKCoordinateRegion(center: center, span: mapView.region.span)
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.presenter.setDestination(nil)
        self.hideDetailsVC()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        if annotation is MKClusterAnnotation {
            return ClusterAnnotationView(annotation: annotation, reuseIdentifier: "reuseis")
        } else {
            return PharmacyAnnotationView(annotation: annotation, reuseIdentifier: PharmacyAnnotationView.reuseID)
        }
       
    }
   
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        if mode == .followWithHeading {
            mapView.setUserTrackingMode(.none, animated: false)
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension MapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
