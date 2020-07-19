//
//  AppDelegate.swift
//  SkeletonPilgrim
//
//  Created by Kyle Wiltshire on 7/16/20.
//

import UIKit
import Pilgrim

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    PilgrimManager.shared().configure(withConsumerKey: "Consumer", secret: "Secret", delegate: self, completion: nil)
    
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}

struct VisitVenue: Codable {
  var name: String
  var lat: CLLocationDegrees
  var lng: CLLocationDegrees
}

extension Notification.Name {
  static let PilgrimVisitNotification = Notification.Name("PilgrimVisitNotification")
}

extension AppDelegate: PilgrimManagerDelegate {
  func pilgrimManager(_ pilgrimManager: PilgrimManager, handle visit: Visit) {
    guard let venue = visit.venue else { return }
    guard let visitLocation = visit.arrivalLocation else { return }
    
    let lastvisit = VisitVenue(name: venue.name, lat: visitLocation.coordinate.latitude, lng: visitLocation.coordinate.longitude)
    
    NotificationCenter.default.post(Notification(name: .PilgrimVisitNotification, object: self, userInfo: ["venue": lastvisit]))
  
    UserDefaults.standard.set(try? PropertyListEncoder().encode(lastvisit), forKey: "lastvisit")
  }
}
