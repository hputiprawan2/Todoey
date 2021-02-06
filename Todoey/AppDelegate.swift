//
//  AppDelegate.swift
//  Todoey
//
//  Created by Hanns Putiprawan on 01/30/2021.
//

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // When the app loads up, happens before viewDidLoad()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try! Realm()
        } catch {
            print("Error initializing new realm \(error)")
        }
        
        return true
    }
}
