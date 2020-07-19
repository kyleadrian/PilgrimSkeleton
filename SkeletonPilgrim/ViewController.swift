//
//  ViewController.swift
//  SkeletonPilgrim
//
//  Created by Kyle Wiltshire on 7/16/20.
//

import UIKit
import MapKit
import CoreLocation
import Pilgrim

class PilgrimSkeletonViewController: UITableViewController {
  @IBOutlet weak var lastVisitUiLabel: UILabel!
  @IBOutlet weak var lastVisitMapView: MKMapView!
  @IBOutlet weak var debugModeButton: UIButton!
  @IBOutlet weak var debugModeSwitch: UISwitch!
  @IBOutlet weak var enableLocationPermissionButton: UIButton!
  @IBOutlet weak var firetTestVisitButton: UIButton!
  @IBOutlet weak var viewDebugLogsButton: UIButton!
  @IBOutlet weak var nearbyLocationUiLabel: UILabel!
  
  private var locationManager: CLLocationManager?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configurelocationManager()
    ensureMapViewUi()
    registerForPilgrimVisitNotifications()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    ensureUi()
  }
  
  @IBAction func enableDebugMode(_ sender: UISwitch) {
    viewDebugLogsButton.isHidden = !sender.isOn
    PilgrimManager.shared().isDebugLogsEnabled = sender.isOn
  }
  
  @IBAction func enableLocationPermission(_ sender: Any) {
    locationManager?.requestAlwaysAuthorization()
  }
  
  @IBAction func fireTestVisit(_ sender: Any) {
    fireTestVisit()
  }
  
  @IBAction func presentDebugViewController(_ sender: UIButton) {
    showDebugViewController()
  }
}

extension PilgrimSkeletonViewController {
  func getCurrentLocation() {
    PilgrimManager.shared().getCurrentLocation { [weak self] (location, error) in
      if let err = error {
        // show alert if error is true
        print(err)
      } else {
        self?.nearbyLocationUiLabel.text = location?.currentPlace.displayName
      }
    }
  }
  
  func fireTestVisit() {
    let ac = UIAlertController(title: "Fire a Test Visit", message: "Choose any venue below to simulate a visit at that location", preferredStyle: .actionSheet)
    
    let shackShackTestVisit = UIAlertAction(title: "Shake Shack", style: .default) { _ in
      PilgrimManager.shared().visitTester?.fireTestVisit(location: CLLocation(latitude: 40.74148371088094, longitude: -73.9882180094719))
      self.tableView.reloadData()
    }
    let madisonSquareGardenTestVisit = UIAlertAction(title: "Madison Square Garden", style: .default) { _ in
      PilgrimManager.shared().visitTester?.fireTestVisit(location: CLLocation(latitude: 40.75075196505169, longitude: -73.99354219436646))
    }
    let empireStateBuildingTestVisit = UIAlertAction(title: "Empire State Building", style: .default) { _ in
      PilgrimManager.shared().visitTester?.fireTestVisit(location: CLLocation(latitude: 40.74665548, longitude: -73.98598909))
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    ac.addAction(shackShackTestVisit)
    ac.addAction(madisonSquareGardenTestVisit)
    ac.addAction(empireStateBuildingTestVisit)
    ac.addAction(cancel)
    
    self.present(ac, animated: true)
  }
  
  func showDebugViewController() {
    PilgrimManager.shared().presentDebugViewController(parentViewController: self)
  }
  
  func configurelocationManager() {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
  }
  
  func ensureUi() {
    debugModeSwitch.isOn = false
    enableLocationPermissionButton.isHidden = isAlwaysOrWhenInUseEnabled()
    firetTestVisitButton.isEnabled = isAlwaysOrWhenInUseEnabled()
    viewDebugLogsButton.isHidden = true
  }
  
  @objc private func configureLastVisitViews(with notification: Notification) {
    guard let visitInfo = notification.userInfo, let venue = visitInfo["venue"] as? VisitVenue else { return }
    lastVisitUiLabel.text = venue.name
    configureMapView(latitude: venue.lat , longitude: venue.lng)
  }
  
  func configureMapView(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    lastVisitMapView.removeAnnotations(lastVisitMapView.annotations)
    
    let annotation = MKPointAnnotation()
    annotation.coordinate.latitude = latitude
    annotation.coordinate.longitude = longitude
    lastVisitMapView.addAnnotation(annotation)
    
    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    lastVisitMapView.setRegion(region, animated: false)
    
  }
  
  func isAlwaysOrWhenInUseEnabled() -> Bool {
    switch locationManager?.authorizationStatus() {
    case .authorizedAlways:
      return true
    case .authorizedWhenInUse:
      return true
    default:
      return false
    }
  }
  
  func ensureMapViewUi() {
    lastVisitMapView.layer.cornerRadius = 10
    lastVisitMapView.layer.masksToBounds = true
  }
  
  func registerForPilgrimVisitNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(configureLastVisitViews(with:)), name: .PilgrimVisitNotification, object: nil)
  }
  
}

extension PilgrimSkeletonViewController: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus() {
    case .authorizedAlways, .authorizedWhenInUse :
      ensureUi()
      PilgrimManager.shared().start()
    case .denied:
      print()
    case .notDetermined:
      print("not determined")
    default:
      break
    }
    
  }
}



