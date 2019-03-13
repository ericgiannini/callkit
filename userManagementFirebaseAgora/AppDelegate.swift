//
//  AppDelegate.swift
//  userManagementFirebaseAgora
//
//  Created by Floyd 2001 on 3/5/19.
//  Copyright © 2019 Agora.io. All rights reserved.
//

import UIKit
import Firebase

let AppID = ""

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        providerDelegate = ProviderDelegate(callManager: callManager)

        return true
    }

    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)?) {
        providerDelegate.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
}

