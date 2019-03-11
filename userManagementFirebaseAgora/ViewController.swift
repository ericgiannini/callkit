//
//  ViewController.swift
//  userManagementFirebaseAgora
//
//  Created by Floyd 2001 on 3/5/19.
//  Copyright © 2019 Agora.io. All rights reserved.
//

import UIKit
import CallKit
import PushKit
import Firebase

class ViewController: UIViewController {
    
    var userAuthenticated: AuthDataResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadCXProviderConfigurations()
         
        loadPKPushRegistration()
        
        print("\(String(describing: userAuthenticated?.user.email))")
        
    }
    
    func loadCXProviderConfigurations() {
        
    let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "CallKit"))
    
    provider.setDelegate(self, queue: nil)
    
    let update = CXCallUpdate()
    
    update.remoteHandle = CXHandle(type: .generic, value: "Eric")
    
    provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }
    
    func loadPKPushRegistration() {
        
        let registry = PKPushRegistry(queue: nil)
        
        registry.delegate = self
        
        registry.desiredPushTypes = [PKPushType.voIP]
        
    }
}

extension ViewController: CXProviderDelegate {
    
    // answer
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
   
    // end
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }

    // reset
    func providerDidReset(_ provider: CXProvider) {
    }
    
}

extension ViewController: PKPushRegistryDelegate {
    
    // update registry with push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        let config = CXProviderConfiguration(localizedName: "CallKit")
        config.iconTemplateImageData = nil
        config.includesCallsInRecents = false
        config.supportsVideo = true
        
        let provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Eric")
        update.hasVideo = true
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: {error in}
        )
    }
}
