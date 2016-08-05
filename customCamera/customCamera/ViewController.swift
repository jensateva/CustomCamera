//
//  ViewController.swift
//  Testing Frameworks
//
//  Created by Jens Wikholm on 25/07/2016.
//  Copyright © 2016 Forbidden Technologies PLC. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var buttonFocusmode: UIButton!
    @IBOutlet weak var buttonRegion: UIButton!
    @IBOutlet weak var buttonQuallity: UIButton!
    @IBOutlet weak var buttonTorchmode: UIButton!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var customSettingsContainer: UIView!
    @IBOutlet weak var focus: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var exitCameraButton: UIButton!
    @IBOutlet weak var playbackBlur: UIVisualEffectView!
    @IBOutlet weak var approveButtonsVIew: UIView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var recordButtonBlurView: UIVisualEffectView!
    @IBOutlet weak var videoControlls: UIView!
//    @IBOutlet weak var faceDetection: UIButton!
//    @IBOutlet weak var settingsContainer: UIView!
//    @IBOutlet weak var doneButton: UIButton!
//    @IBOutlet weak var torchMode: UIButton!
//    @IBOutlet weak var frameRateButton: UIButton!
//    @IBOutlet weak var focusModeButton: UIButton!
//    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var playButtonBlurView: UIVisualEffectView!
//    @IBOutlet weak var videoResolutionButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var labelDuration: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playbackContainer: UIView!
    @IBOutlet weak var overlayBlur: UIVisualEffectView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerStartStopButton: UIButton!
    @IBOutlet weak var uploadProgress: UIProgressView!

    var lastRecordedMovie = NSURL()
    let CameraLibrary = ForsceneCamera()
    let Engine = CameraEngine()
    let defaults = NSUserDefaults()

    var FRAMERATE = Int()
    var FOCUSMODE = String()
    var moviePlayer : MPMoviePlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        Engine.startSession()

        let image = defaults.valueForKey("logo") as! String
        self.logoImage.image = UIImage(named:image)

        Engine.blockCompletionProgress = { progress in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.labelDuration.hidden = false

                let time = Int(progress)
                let minutes = Int(time) / 60 % 60
                let seconds = Int(time) % 60
                let secondsString = (String(format: "%02d", seconds))
                let minutesString = (String(format: "%02d", minutes))
                self.labelDuration.text = minutesString.stringByAppendingString(":").stringByAppendingString(secondsString)
            })
        }

        // ADD ZOOM GESTURE
        let twoFingerPinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.onTwoFingerPinch(_:)))
        self.view.addGestureRecognizer(twoFingerPinch)
        self.view.userInteractionEnabled = true

        // FACE DETECTION
        Engine.blockCompletionFaceDetection = { faceObject in
            print("face Object")
            (faceObject as AVMetadataObject).bounds
        }

        // QRCODE DETECTION
        Engine.blockCompletionCodeDetection = { codeObject in
            print("code object value : \(codeObject.stringValue)")
        }

        // SETUP VIEW
        setUpView()
        dispatch_async(dispatch_get_main_queue()){
        let layer = self.Engine.previewLayer
        layer.frame = self.view.bounds
        self.cameraView.layer.insertSublayer(layer, atIndex: 0)
        self.cameraView.layer.masksToBounds = true
        }
    }

    override func viewDidLayoutSubviews() {
          dispatch_async(dispatch_get_main_queue()){
        let layer = self.Engine.previewLayer
        layer.frame = self.view.bounds
        self.cameraView.layer.insertSublayer(layer, atIndex: 0)
        self.cameraView.layer.masksToBounds = true
        }
    }

    override func viewDidAppear(animated: Bool) {
        Engine.rotationCamera = true
        self.blurOff()
        self.hideLogo()
        self.showCameraControlls()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        Engine.rotationCamera = false
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("Landscape")
            // TODO - SET LOCATION FOR RECORS BUTTONS
        } else {
            print("Portrait")
            // TODO - SET LOCATION FOR RECORS BUTTONS
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    func showMessage(message:String){

        dispatch_async(dispatch_get_main_queue())
        {
            self.userMessage.alpha = 0.0
            self.userMessage.text = message

            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {

                self.userMessage.alpha = 1.0

                }, completion: { finished in

                    UIView.animateWithDuration(0.25, delay: 0.4, options: .CurveEaseOut, animations: {

                        self.userMessage.alpha = 0.0

                        }, completion: { finished in
                    })
            })
        }
    }


    func setUpView(){

        let defaults = NSUserDefaults()
        FRAMERATE = defaults.integerForKey("frameRate")

        if FRAMERATE > 25
        {
            self.buttonRegion.setImage(getUIImage("icon_ntsc.png"), forState: .Normal)
            self.buttonRegion.setTitle("25", forState: .Normal)
        }
        else
        {
            self.buttonRegion.setImage(getUIImage("icon_pal.png"), forState: .Normal)
        }

        if defaults.boolForKey("showCustomSettings")
        {
            self.labelDuration.hidden = true
            self.settingsIcon.hidden = true
            self.customSettingsContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, 50)
            self.customSettingsContainer.hidden = false
            self.customSettingsContainer.alpha = 1.0
        }
        else
        {
            self.customSettingsContainer.frame = CGRectMake(0, -50, self.view.frame.size.width, 50)
            self.customSettingsContainer.hidden = true
        }

        if defaults.boolForKey("hideExitButton")
        {
            self.labelDuration.hidden = false
            self.exitCameraButton.hidden = true
            self.customSettingsContainer.frame = CGRectMake(0, -50, self.view.frame.size.width, 50)
            self.customSettingsContainer.hidden = true
            self.customSettingsContainer.alpha = 0.0
        }

        self.labelDuration.text = "00:00"
        self.recordButtonBlurView.layer.cornerRadius = self.recordButtonBlurView.frame.size.width / 2
        self.recordButtonBlurView.layer.masksToBounds = true
        self.playButtonBlurView.layer.cornerRadius = self.recordButtonBlurView.frame.size.width / 2
        self.playButtonBlurView.layer.masksToBounds = true
        self.switchButton.alpha = 1.0
    }

    func hideLogo(){

        UIView.animateWithDuration(0.3, delay: 0.35, options: .CurveEaseOut, animations: {

            self.logoImage.frame = CGRectMake(-100, -80, self.view.frame.size.width + 200 , self.view.frame.size.height + 160)
            self.logoImage.alpha = 0.0

            }, completion: { finished in
                self.logoImage.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        })
    }

    func blurOff(){
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.overlayBlur.alpha = 0.0
            }, completion: { finished in
        })
    }

    func blurOn(){
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {

            self.overlayBlur.alpha = 1.0
            }, completion: { finished in
        })
    }

    func playbackBlurOff(){
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {

            self.playbackBlur.alpha = 0.0
            }, completion: { finished in

        })
    }

    func playbackBlurOn(){
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.playbackBlur.alpha = 1.0
            }, completion: { finished in

        })
    }

    func showCameraControlls(){
        UIView.animateWithDuration(0.4, delay: 1.0, options: .CurveEaseOut, animations: {
            self.videoControlls.alpha = 1.0
            }, completion: { finished in

        })
    }

    func hideCameraControlls(){
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {
            self.videoControlls.alpha = 0.0
            }, completion: { finished in

        })
    }





    func animateRecording(){
        self.recordButton.setImage(getUIImage("record_recording.png"), forState: .Normal)
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {

            self.switchButton.alpha = 0.0
            self.settingsIcon.alpha = 0.0
            self.exitCameraButton.alpha = 0.0

            }, completion: { finished in
                self.hideCustomSettingsShowTimer()
        })
    }

    func animateBackTorecord(){

        self.blurOff()
        let defaults = NSUserDefaults()
        if defaults.boolForKey("showCustomSettings")
        {
            self.showCustomSettingsHideTimer()
        }
        else
        {
            self.labelDuration.frame = CGRectMake(0, -50, self.view.frame.size.width, 50)
            self.labelDuration.alpha = 0.0
        }

        if defaults.boolForKey("hideExitButton")
        {
            self.labelDuration.hidden = false
            self.customSettingsContainer.hidden = true
            self.exitCameraButton.hidden = true
        }

        self.labelDuration.text = "00:00"
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.videoView.frame = CGRectMake(0, -200, self.view.frame.size.width, self.view.frame.size.height)
            self.cameraView.frame = CGRectMake( 0, 0, self.view.frame.size.width, self.view.frame.size.height)

            self.settingsIcon.alpha = 1.0
            self.videoView.alpha = 0.0
            self.videoView.hidden = false
            self.switchButton.alpha = 1.0
            self.exitCameraButton.alpha = 1.0
            self.videoControlls.alpha = 1.0
            self.videoControlls.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.approveButtonsVIew.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 140)
            self.approveButtonsVIew.alpha = 0.0
            }, completion: { finished in
        })
    }

    func hideCustomSettingsShowTimer(){

        self.labelDuration.alpha = 0.0
        self.labelDuration.frame = CGRectMake(0, 50, self.view.frame.size.width, 50)

        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.labelDuration.hidden = false
            self.labelDuration.alpha = 1.0
            self.labelDuration.frame = CGRectMake(0, 0, self.view.frame.size.width, 50)
            self.customSettingsContainer.frame = CGRectMake(0, -50, self.view.frame.size.width, 50)
            self.customSettingsContainer.alpha = 0.0

            }, completion: { finished in

        })
    }

    func showCustomSettingsHideTimer(){

        self.labelDuration.alpha = 0.0
        self.labelDuration.hidden = false
        self.labelDuration.frame = CGRectMake(0, 50, self.view.frame.size.width, 50)

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {

            self.customSettingsContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, 50)
            self.customSettingsContainer.alpha = 1.0

            }, completion: { finished in

        })
    }



    func animateStopRecording(){

        self.recordButton.setImage(getUIImage("record_start.png"), forState: .Normal)

        UIView.animateWithDuration(0.4, delay: 0.2, options: .CurveEaseOut, animations: {

            self.videoControlls.alpha = 0.0
            self.approveButtonsVIew.frame = CGRectMake(0, self.view.frame.size.height - 120, self.view.frame.size.width, 140)
            self.approveButtonsVIew.alpha = 1.0
            self.videoControlls.frame = CGRectMake(0, -120, self.view.frame.size.width, self.view.frame.size.height)

            self.videoView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.cameraView.frame = CGRectMake(0, -200, self.view.frame.size.width, self.view.frame.size.height)

            self.switchButton.alpha = 0.0
            self.videoView.alpha = 1.0
            self.videoView.hidden = false


            }, completion: { finished in

                self.PlayPreviewMoview(self.lastRecordedMovie)
        })
    }


    // MARK - Player

    func PlayPreviewMoview (url : NSURL){

        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(ViewController.MPMoviePlayerPlaybackStateDidChange(_:)),
            name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)

        self.moviePlayer = MPMoviePlayerViewController(contentURL: url )
        if let player = self.moviePlayer {
            player.view.frame = self.view.bounds
            player.view.sizeToFit()
            player.moviePlayer.scalingMode = .AspectFit
            player.moviePlayer.view.backgroundColor = UIColor.blackColor()
            player.moviePlayer.backgroundView.backgroundColor = UIColor.blackColor()
            player.moviePlayer.controlStyle = .None
            self.playbackContainer.addSubview(player.view)
        }
    }


    func MPMoviePlayerPlaybackStateDidChange(notification: NSNotification)
    {
        if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Playing
        {
            print("playing")
            self.playerStartStopButton.setImage(getUIImage("stop.png"), forState: .Normal)
            self.overlayBlur.alpha = 0.0
            self.playbackBlurOff()
        }
        else if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Stopped
        {
            print("stopped")
            self.playerStartStopButton.setImage(getUIImage("play.png"), forState: .Normal)
            self.playbackBlurOn()
        }
        else if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Paused
        {
            print("paused")
            self.playerStartStopButton.setImage(getUIImage("play.png"), forState: .Normal)
            self.playbackBlurOn()
        }
        else if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Interrupted
        {
            print("interupted")
            self.playerStartStopButton.setImage(getUIImage("play.png"), forState: .Normal)
            self.playbackBlurOn()
        }
    }





    func startStopMovie(){
        if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Stopped
        {
            self.moviePlayer?.moviePlayer.play()
        }
        if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Paused
        {
            self.moviePlayer?.moviePlayer.play()
        }
        else{
            self.moviePlayer?.moviePlayer.pause()
        }
    }




    // MARK - IBActions

    @IBAction func backToRecord(sender: UIButton) {
        self.moviePlayer?.moviePlayer.stop()
        self.animateBackTorecord()
    }


    @IBAction func playMovie(sender: UIButton) {
        startStopMovie()
    }

    @IBAction func approve(sender: UIButton) {

        self.moviePlayer?.moviePlayer.stop()
        print("Video approved")

        if defaults.boolForKey("uploadVideo")
        {
            self.UploadVideo(lastRecordedMovie)
        }
        else
        {
            let NOTIFICATIONS = NSNotificationCenter.defaultCenter()
            NOTIFICATIONS.postNotificationName("VideoRecorded", object: lastRecordedMovie)
        }

        if defaults.boolForKey("multirecord")
        {
            print("Multirecord is set to True we will display upload bar on Camera UI")
            self.uploadProgress.progress = 0.0
            self.animateBackTorecord()
        }
        else
        {

            self.dismissViewControllerAnimated(true) {
                self.animateBackTorecord()
                print("User approved a video you could show upload status on main UI")

                let progressBar = UIProgressView()
                let vc = currentView
                vc.view.addSubview(progressBar)
            }
        }
    }



    @IBAction func changeRegion(sender: UIButton) {
        if FRAMERATE > 25
        {
            print("PAL 25")
            self.Engine.changeFrameRate(25)
            FRAMERATE = 25
            self.showMessage("25 fps")
            self.buttonRegion.setImage(getUIImage("icon_pal.png"), forState: .Normal)
        }
        else
        {
            print("NTSC 30")
            self.Engine.changeFrameRate(30)
            FRAMERATE = 30
            self.showMessage("30 fps")
            self.buttonRegion.setImage(getUIImage("icon_ntsc.png"), forState: .Normal)
        }
    }


    @IBAction func showPreview(sender: UIButton) {
        startStopMovie()
    }




    @IBAction func switchCamera(sender: AnyObject) {
        self.Engine.switchCurrentDevice()

        UIView.animateWithDuration(0.35, animations:{
            self.switchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
        })
    }


    @IBAction func exitCamera(sender: UIButton) {
        self.dismissViewControllerAnimated(true) {
            print("Forscene Camera Dismissed")
        }
    }


    @IBAction func changeQuallity(sender: AnyObject) {

        if self.Engine.videoEncoderPresset == CameraEngineVideoEncoderEncoderSettings.Preset1280x720
        {
            self.Engine.videoEncoderPresset = CameraEngineVideoEncoderEncoderSettings.Preset1920x1080
            self.buttonQuallity.setImage(getUIImage("icon_hd.png"), forState: .Normal)
            self.showMessage("1080p")
        }
        else  if self.Engine.videoEncoderPresset == CameraEngineVideoEncoderEncoderSettings.Preset1920x1080
        {
            self.Engine.videoEncoderPresset = CameraEngineVideoEncoderEncoderSettings.Preset3840x2160
            self.buttonQuallity.setImage(getUIImage("icon_4k.png"), forState: .Normal)
            self.showMessage("4k")
        }
        else
        {
            self.Engine.videoEncoderPresset = CameraEngineVideoEncoderEncoderSettings.Preset1280x720
            self.buttonQuallity.setImage(getUIImage("icon_sd.png"), forState: .Normal)
            self.showMessage("720p")
        }

        print("Video Resolution is: :\(self.Engine.videoEncoderPresset)")
    }


    @IBAction func changeFocusmode(sender: UIButton)
    {
        if FOCUSMODE == "AUTO"
        {
            self.buttonFocusmode.setImage(getUIImage("icon_focus_continious"), forState: .Normal)
            Engine.cameraFocus = CameraEngineCameraFocus.ContinuousAutoFocus
            self.showMessage("Continious")
            FOCUSMODE = "CONTINIOUS"
        }
        else if FOCUSMODE == "CONTINIOUS"
        {
            self.buttonFocusmode.setImage(getUIImage("icon_focus_locked"), forState: .Normal)
            Engine.cameraFocus = CameraEngineCameraFocus.Locked
            self.showMessage("Focus locked")
            FOCUSMODE = "LOCKED"
        }
        else if FOCUSMODE == "LOCKED"
        {
            self.buttonFocusmode.setImage(getUIImage("icon_focus_auto"), forState: .Normal)
            Engine.cameraFocus = CameraEngineCameraFocus.AutoFocus
            self.showMessage("Auto focus")
            FOCUSMODE = "AUTO"
        }
        else
        {
            self.buttonFocusmode.setImage(getUIImage("icon_focus_auto"), forState: .Normal)
            Engine.cameraFocus = CameraEngineCameraFocus.AutoFocus
            self.showMessage("Auto focus")
            FOCUSMODE = "AUTO"
        }
    }



    @IBAction func changeTorchMode(sender: AnyObject)
    {
        if self.Engine.torchMode ==  AVCaptureTorchMode.Off
        {
            self.Engine.torchMode = .On
            self.buttonTorchmode.setImage(getUIImage("icon_flash_on"), forState: .Normal)
            self.showMessage("Torch on")
        }

        else if self.Engine.torchMode ==  AVCaptureTorchMode.On
        {
            self.Engine.torchMode = .Auto
            self.buttonTorchmode.setImage(getUIImage("icon_flash_auto"), forState: .Normal)
            self.showMessage("Torch auto")
        }
        else
        {
            self.Engine.torchMode = .Off
            self.buttonTorchmode.setImage(getUIImage("icon_flash_off"), forState: .Normal)
            self.showMessage("Torch off")
            
        }
    }


    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        print("LONGPRESS")
        self.buttonFocusmode.setImage(getUIImage("icon_focus_locked"), forState: .Normal)
        Engine.cameraFocus = CameraEngineCameraFocus.Locked
        self.showMessage("Focus locked")
        FOCUSMODE = "LOCKED"
    }




    @IBAction func startRecord(sender: UIButton)
    {
        print("Recording video...")
        if Engine.isRecording == false {

            dispatch_async(dispatch_get_main_queue()){
                self.animateRecording()
            }

            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy_HH:mm:ss"
            let dateStr = dateFormatter.stringFromDate(date)
            let videoFileName =  dateStr + "_Forscene.mp4"

            guard let url = CameraEngineFileManager.documentPath(videoFileName) else {
                return
            }

            Engine.startRecordingVideo(url, blockCompletion: { (url, error) -> (Void) in

                self.lastRecordedMovie = url!


                if self.defaults.boolForKey("saveOriginal") {

                    CameraEngineFileManager.saveVideo(url!, blockCompletion: { (success, error) -> (Void) in
                        print("Error saving the video : \(error)")
                        print("Original video saved : \(success)")
                    })
                }
            })
        }
        else
        { Engine.stopRecordingVideo()
            dispatch_async(dispatch_get_main_queue()){
               // self.PlayPreviewMoview(self.lastRecordedMovie)
                self.animateStopRecording()
            }
        }
    }




    // MARK - APIs

    private func UploadVideo(urlString:NSURL)
    {
        print("Starting upload...")
        uploadProgress.hidden = false
        uploadProgress.alpha = 1.0

        let TOKEN = defaults.valueForKey("token") as! String
        let UPLOADURL = defaults.valueForKey("uploadurl") as! String
        let FOLDER = defaults.valueForKey("folderName") as! String
        let HEADERS = ["X-Auth-Kestrel":TOKEN]

        let today = NSDate.distantPast()
        NSHTTPCookieStorage.sharedHTTPCookieStorage().removeCookiesSinceDate(today)

        let task = NetworkManager.sharedManager.backgroundTask
        task.upload(

            .POST,UPLOADURL,
            headers: HEADERS,
            multipartFormData: { multipartFormData in

                multipartFormData.appendBodyPart(fileURL: urlString, name: "uploadfile")
                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "format")
                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "aspect")
                multipartFormData.appendBodyPart(data: FOLDER .dataUsingEncoding(NSUTF8StringEncoding)!, name: "location")

            },

            encodingCompletion: { encodingResult in

                switch encodingResult {
                case .Success(let upload,  _,  _):

                    upload.progress {  bytesRead, totalBytesRead, totalBytesExpectedToRead in

                        print("Uploading :\(Int32(totalBytesRead) / Int32(totalBytesExpectedToRead) * 100)")
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.uploadProgress.progress = (Float(totalBytesRead) / Float(totalBytesExpectedToRead))
                        }
                    }
                    upload.responseJSON { response in

                        print("Successfully uploaded!")
                        self.uploadProgress.progress = 0.0
                        self.uploadProgress.alpha = 0.0
                    }
                case .Failure(let encodingError):

                    print(encodingError)
                    self.uploadProgress.progress = 0.0
                    self.uploadProgress.alpha = 0.0
                    
                }
            }
        )
    }
    

    
    // MARK - Gestures

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = event!.allTouches()!.first {
            let position = touch.locationInView(self.view)
            
            Engine.focus(position)
            self.showTouch(position)
        }
    }
    
    
    func showTouch(position : CGPoint){
        
        self.focus.frame = CGRectMake(position.x - 10 , position.y - 10, 20, 20)
        
        if position.y > 50 && position.y < self.view.frame.height - 100
        {
            
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 4.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
                
                self.focus.alpha = 1.0
                self.focus.frame = CGRectMake(position.x - 40, position.y - 40, 80, 80)
            }), completion: { finished in
                
                UIView.animateWithDuration(0.35, delay: 0.6, usingSpringWithDamping: 0.3, initialSpringVelocity: 3.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: ({
                    
                    self.focus.alpha = 0.0
                    self.focus.frame = CGRectMake(position.x - 10 , position.y - 10, 20, 20)
                }), completion: { finished in
                })
            })
        }
    }
    
    
    @objc func onTwoFingerPinch(recognizer: UIPinchGestureRecognizer) {
        let maxZoom: CGFloat = 6.0
        let pinchVelocityDividerFactor: CGFloat = 5.0
        if recognizer.state == .Changed {
            self.focus.alpha = 0.0
            let desiredZoomFactor = min(maxZoom, Engine.cameraZoomFactor + atan2(recognizer.velocity, pinchVelocityDividerFactor))
            Engine.cameraZoomFactor = desiredZoomFactor
        }
    }
    
    func getUIImage(image : String) -> UIImage
    {
        let image = UIImage(named: image, inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
        return image!
    }
    
    
}

