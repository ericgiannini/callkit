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
import AgoraRtcEngineKit

class ViewController: UIViewController {
    
    var userAuthenticated: AuthDataResult?
    
    var localizedName: String = ""

    var agoraKit: AgoraRtcEngineKit!

    @IBOutlet weak var labelLocalizedName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadCXProviderConfigurations()
         
        loadPKPushRegistration()
        
        print("\(String(describing: userAuthenticated?.user.email))")
        
        if let unwrapped = userAuthenticated?.user.email {
            localizedName = unwrapped
        }
        
        labelLocalizedName.text = localizedName
        
        initializeAgoraEngine()
        
        setupVideo()
        
        setChannelProfile()
        
    }
    
    
    func initializeAgoraEngine() {
        
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
        
    }
    
    func setupVideo() {
        
        agoraKit.enableVideo()
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360, frameRate: .fps15, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative))
        
    }
    
    func setChannelProfile() {
        agoraKit.setChannelProfile(.communication)
    }

    func joinChannel() {
        
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        agoraKit.joinChannel(byToken: nil, channelId: "DemoChannel", info: nil, uid: 0) { [weak self] (sid, uid, elapsed) -> Void in
        
        guard let _self = self else { return }
        DispatchQueue.main.async {
        _self.setupLocalVideo(uid: uid)
        }
    }
    UIApplication.shared.isIdleTimerDisabled = true
}
    
    func setupLocalVideo(uid: UInt) {
        
        let videoView = UIView()
        videoView.tag = Int(uid)
        videoView.backgroundColor = UIColor.orange
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = videoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        
//        stackView.addArrangedSubview(videoView)
        
    }
    
    
    
    func loadCXProviderConfigurations() {
        
    let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: localizedName))
    
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

extension ViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        let videoView = UIView()
        videoView.tag = Int(uid)
        videoView.backgroundColor = UIColor.purple
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = videoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
        
//        stackView.addArrangedSubview(view)
        
    }
    
    internal func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        
//        guard let view = stackView.arrangedSubviews.first(where: { (view) -> Bool in
//            return view.tag == Int(uid)
//        }) else { return }
        
//        stackView.removeArrangedSubview(view)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
        //
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
        
        let config = CXProviderConfiguration(localizedName: localizedName)
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
