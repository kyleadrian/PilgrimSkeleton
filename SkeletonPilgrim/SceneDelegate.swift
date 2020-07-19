//
//  SceneDelegate.swift
//  SkeletonPilgrim
//
//  Created by Kyle Wiltshire on 7/16/20.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let _ = (scene as? UIWindowScene) else { return }
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    guard let vc = window?.rootViewController as? PilgrimSkeletonViewController else { return }
    
    if let data = UserDefaults.standard.data(forKey: "lastvisit") {
      if let lastVisit = try? PropertyListDecoder().decode(VisitVenue.self, from: data) {
        vc.lastVisitUiLabel.text = lastVisit.name
        vc.configureMapView(latitude: lastVisit.lat, longitude: lastVisit.lng)
      }
    }
    
    vc.getCurrentLocation()
  }
}

