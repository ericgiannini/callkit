import UIKit
import Firebase
import AgoraRtcEngineKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    
    var userAuthenticated: AuthDataResult?
    
    var valueName: String = ""
    
    var agoraKit: AgoraRtcEngineKit!
    
    @IBOutlet weak var labelLocalizedName: UILabel!
    
    let localUID = UInt(UUID().hashValue)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelLocalizedName.text = valueName
        
        initializeAgoraEngine()
        
        setupVideo()
        
        setChannelProfile()
        
        joinChannel()
    }
    
    func fakeCallKit() {
        
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
    
    @IBAction func simulateMakingACall(_ sender: Any) {
        AppDelegate.shared.callManager.startCall(handle: valueName, videoEnabled: true)
    }
    
    @IBAction func makingACall(_ sender: Any) {
        self.setupLocalVideo(uid: localUID)
    }
    
    @IBAction func simulateReceivingACall(_ sender: Any) {
        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
            AppDelegate.shared.displayIncomingCall(uuid: UUID(), handle: self.valueName, hasVideo: true) { error in
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                if error == nil {
                    self.setupLocalVideo(uid: self.localUID)
                }
            }
        }
    }
    
    @IBAction func endCall(_ sender: Any) {
        agoraKit.leaveChannel(nil)
        UIApplication.shared.isIdleTimerDisabled = false
        
        guard let view = stackView.arrangedSubviews.first(where: { (view) -> Bool in
            return view.tag == localUID
        }) else { return }
        
        stackView.removeArrangedSubview(view)
    }
    
    func joinChannel() {
        
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        agoraKit.joinChannel(byToken: nil, channelId: "DemoChannel", info: nil, uid: localUID) { (sid, uid, elapsed) -> Void in
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
        
        stackView.addArrangedSubview(videoView)
    }
}

extension ViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        print(#function)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        
        print(#function)
        let videoView = UIView()
        videoView.tag = Int(uid)
        videoView.backgroundColor = UIColor.purple
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = videoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
        
        self.stackView.addArrangedSubview(videoView)
    }
    
    internal func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        
        guard let view = stackView.arrangedSubviews.first(where: { (view) -> Bool in
            return view.tag == Int(uid)
        }) else { return }
        
        stackView.removeArrangedSubview(view)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
        //
    }
}
