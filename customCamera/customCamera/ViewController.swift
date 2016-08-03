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

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var exitCameraButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var iconDetection: UIImageView!
    @IBOutlet weak var iconTorch: UIImageView!
    @IBOutlet weak var iconFocus: UIImageView!
    @IBOutlet weak var iconFramerate: UIImageView!
    @IBOutlet weak var iconResolution: UIImageView!
    @IBOutlet weak var playbackBlur: UIVisualEffectView!
    @IBOutlet weak var approveButtonsVIew: UIView!
    @IBOutlet weak var switchButton: UIButton!
    @IBOutlet weak var recordButtonBlurView: UIVisualEffectView!
    @IBOutlet weak var videoControlls: UIView!
    @IBOutlet weak var faceDetection: UIButton!
    @IBOutlet weak var settingsContainer: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var torchMode: UIButton!
    @IBOutlet weak var frameRateButton: UIButton!
    @IBOutlet weak var focusModeButton: UIButton!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var playButtonBlurView: UIVisualEffectView!
    @IBOutlet weak var videoResolutionButton: UIButton!
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


    var moviePlayer : MPMoviePlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        Engine.startSession()

        let image = defaults.valueForKey("logo") as! String
        self.logoImage.image = UIImage(named:image)

        Engine.blockCompletionProgress = { progress in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.labelDuration.hidden = false

                // TODO - Add Frames per second after seconds
                let time = Int(progress)
                let minutes = Int(time) / 60 % 60
                let seconds = Int(time) % 60
                //let milliSeconds = Int(time) % 60
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

        Engine.blockCompletionCodeDetection = { codeObject in
            print("code object value : \(codeObject.stringValue)")
        }
        // SETUP VIEW
        setUpView()


        // Add Camera View Here As Well Loads Quicker then
        let layer = Engine.previewLayer
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, atIndex: 0)
        self.view.layer.masksToBounds = true

    }

    override func viewDidLayoutSubviews() {
        let layer = Engine.previewLayer
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, atIndex: 0)
        self.view.layer.masksToBounds = true
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


    func setupPortraitView(){
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        let height = bounds.size.height

        self.settingsContainer.frame = CGRectMake(50, height / 2  - width / 2, width - 100  , width )
        let buttonHeight = width / 6
        self.faceDetection.frame = CGRectMake(buttonHeight, 0, self.view.frame.size.width - buttonHeight, buttonHeight)
        self.torchMode.frame = CGRectMake(buttonHeight, buttonHeight * 1, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)
        self.focusModeButton.frame = CGRectMake(buttonHeight, buttonHeight * 2, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)
        self.frameRateButton.frame = CGRectMake(buttonHeight, buttonHeight * 3, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)
        self.videoResolutionButton.frame = CGRectMake(buttonHeight, buttonHeight * 4, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)

        self.iconDetection.frame = CGRectMake(0, 0, buttonHeight, buttonHeight)
        self.iconTorch.frame = CGRectMake(0, buttonHeight, buttonHeight, buttonHeight)
        self.iconFocus.frame = CGRectMake(0, buttonHeight * 2, buttonHeight, buttonHeight)
        self.iconFramerate.frame = CGRectMake(0, buttonHeight * 3, buttonHeight, buttonHeight)
        self.iconResolution.frame = CGRectMake(0, buttonHeight * 4, buttonHeight, buttonHeight)

    }

    func setUpView(){

        let defaults = NSUserDefaults()
        if defaults.boolForKey("showCustomSettings")
        {
            self.labelDuration.hidden = true
            self.settingsButton.hidden = false
            self.settingsIcon.hidden = true
        }

        if defaults.boolForKey("hideExitButton")
        {
            self.labelDuration.hidden = false
            self.settingsButton.hidden = true
            self.settingsIcon.hidden = false
            self.exitCameraButton.hidden = true
        }


        self.labelDuration.text = "00:00"
        self.recordButtonBlurView.layer.cornerRadius = self.recordButtonBlurView.frame.size.width / 2
        self.recordButtonBlurView.layer.masksToBounds = true
        self.playButtonBlurView.layer.cornerRadius = self.recordButtonBlurView.frame.size.width / 2
        self.playButtonBlurView.layer.masksToBounds = true
        self.switchButton.alpha = 1.0
        self.settingsButton.alpha = 1.0
        self.setupPortraitView()
    }

    func hideLogo(){
        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: {
            self.logoImage.alpha = 0.0
            }, completion: { finished in

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

    @IBAction func exitCamera(sender: UIButton) {
        self.dismissViewControllerAnimated(true) {
            print("Forscene Camera Dismissed")
        }
    }

    func animateRecording(){

        self.labelDuration.hidden = false
        self.settingsButton.hidden = true

        let image = UIImage(named: "record_recording.png") as UIImage?
        self.recordButton.setImage(image, forState: .Normal)

        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {

            self.switchButton.alpha = 0.0
            self.settingsButton.alpha = 0.0
            self.settingsIcon.alpha = 0.0
            self.exitCameraButton.alpha = 0.0

            }, completion: { finished in
        })
    }

    func animateStopRecording(){

        self.blurOn()
        let image = UIImage(named: "record_start.png") as UIImage?
        self.recordButton.setImage(image, forState: .Normal)

        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.videoControlls.alpha = 0.0
            self.approveButtonsVIew.frame = CGRectMake(0, self.view.frame.size.height - 120, self.view.frame.size.width, 140)
            self.approveButtonsVIew.alpha = 1.0
            self.videoControlls.frame = CGRectMake(0, -120, self.view.frame.size.width, self.view.frame.size.height)

            }, completion: { finished in

                self.animateShowPreview()
                self.PlayPreviewMoview(self.lastRecordedMovie)
        })
    }

    @IBAction func showPreview(sender: UIButton) {
        startStopMovie()
    }

    func animateShowPreview(){
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.switchButton.alpha = 0.0
            self.settingsButton.alpha = 0.0
            self.videoView.alpha = 1.0
            self.videoView.hidden = false

            }, completion: { finished in
                self.blurOff()
        })
    }

    @IBAction func backToRecord(sender: UIButton) {
        self.animateBackTorecord()
    }

    @IBAction func approve(sender: UIButton) {

        print("APPROVE BUTTON CLICKED")
        print(lastRecordedMovie)
        self.UploadVideo(lastRecordedMovie)

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



    private func UploadVideo(urlString:NSURL)
    {
        print("START UPLOAD")
        print(urlString)

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

                        print(bytesRead)

                        // Show upload progress if user is multi recording
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.uploadProgress.progress = (Float(totalBytesRead) / Float(totalBytesExpectedToRead))
                        }
                    }

                    //TODO: Check Json response correctly
                    upload.responseJSON { response in

                        print("FORSCENE UPLOAD SUCCESS")
                        self.uploadProgress.progress = 0.0
                    }
                case .Failure(let encodingError):

                    print(encodingError)
                    self.uploadProgress.progress = 0.0

                }
            }
        )
    }


    func animateBackTorecord(){

        self.blurOff()

        let defaults = NSUserDefaults()
        if defaults.boolForKey("showCustomSettings")
        {
            self.labelDuration.hidden = true
            self.settingsButton.hidden = false
        }

        if defaults.boolForKey("showCustomSettings")
        {
            self.labelDuration.hidden = true
            self.settingsButton.hidden = false
            self.settingsIcon.hidden = true
        }

        if defaults.boolForKey("hideExitButton")
        {
            self.labelDuration.hidden = false
            self.settingsButton.hidden = true
            self.settingsIcon.hidden = false
            self.exitCameraButton.hidden = true
        }

        self.labelDuration.text = "00:00"
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.settingsIcon.alpha = 1.0
            self.videoView.alpha = 0.0
            self.videoView.hidden = false
            self.switchButton.alpha = 1.0
            self.exitCameraButton.alpha = 1.0
            self.settingsButton.alpha = 1.0
            self.videoControlls.alpha = 1.0
            self.videoControlls.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.approveButtonsVIew.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 140)
            self.approveButtonsVIew.alpha = 0.0
            }, completion: { finished in

        })

    }

    @IBAction func switchCamera(sender: AnyObject) {
        self.Engine.switchCurrentDevice()
    }

    @IBAction func revealSettings(sender: UIButton) {
        blurOn()

        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.settingsView.alpha = 1.0
            self.settingsView.hidden = false
            self.videoControlls.alpha = 0.0

            }, completion: { finished in

        })
    }

    @IBAction func hideSettings(sender: UIButton)
    {
        self.blurOff()
        self.settingsView.alpha = 0.0
        self.settingsView.hidden = true
        self.videoControlls.alpha = 1.0
    }

    @IBAction func Quallity(sender: AnyObject) {

        let pressetCompatible = Engine.compatibleVideoEncoderPresset()
        let alertController = UIAlertController(title: "Video Resolution", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        for currentPresset in pressetCompatible {
            alertController.addAction(UIAlertAction(title: currentPresset.description(), style: UIAlertActionStyle.Default, handler: { (_) -> Void in
                self.Engine.videoEncoderPresset = currentPresset
                let size = String(currentPresset).stringByReplacingOccurrencesOfString("Preset", withString: "")
                self.videoResolutionButton.setTitle(size, forState: UIControlState.Normal)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func setAllSettingValues () {
        let defaults = NSUserDefaults()
        if defaults.objectForKey("frameRate") != nil{
            let frameRate = defaults.valueForKey("frameRate") as! String
            self.frameRateButton.setTitle(frameRate, forState: .Normal)
            let rate = Int32(frameRate)! as Int32
            self.Engine.changeFrameRate(rate)
        }
        else {
            self.frameRateButton.setTitle("30", forState: .Normal)

        }
    }


    @IBAction func changeTorchMode(sender: AnyObject) {
        let alertController = UIAlertController(title: "Torch mode", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        alertController.addAction(UIAlertAction(title: "On", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
            self.Engine.torchMode = .On
            self.torchMode.setTitle("Torch On", forState: .Normal)
        }))
        alertController.addAction(UIAlertAction(title: "Off", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
            self.Engine.torchMode = .Off
            self.torchMode.setTitle("Torch Off", forState: .Normal)
        }))
        alertController.addAction(UIAlertAction(title: "Auto", style: UIAlertActionStyle.Default, handler: { (_) -> Void in
            self.Engine.torchMode = .Auto
            self.torchMode.setTitle("Torch Auto", forState: .Normal)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }


    @IBAction func changeDetectionMode(sender: AnyObject) {
        let detectionCompatible = self.Engine.compatibleDetectionMetadata()
        let alertController = UIAlertController(title: "Camera detection", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        for currentDetectionMode in detectionCompatible {
            alertController.addAction(UIAlertAction(title: currentDetectionMode.description(), style: UIAlertActionStyle.Default, handler: { (_) -> Void in
                self.Engine.metadataDetection = currentDetectionMode
                let detectionMode = String(currentDetectionMode)
                self.faceDetection.setTitle(detectionMode, forState: .Normal)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }


    @IBAction func changeFocusCamera(sender: AnyObject) {
        let focusCompatible = self.Engine.compatibleCameraFocus()

        let alertController = UIAlertController(title: "Camera focus", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        for currentFocusMode in focusCompatible {
            alertController.addAction(UIAlertAction(title: currentFocusMode.description(), style: UIAlertActionStyle.Default, handler: { (_) -> Void in
                self.Engine.cameraFocus = currentFocusMode
                let focusModeString = String(currentFocusMode)
                self.focusModeButton.setTitle(focusModeString, forState: .Normal)
            }))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }


    @IBAction func changeFrameRate(sender: AnyObject) {

        let defaults = NSUserDefaults()
        let alertController = UIAlertController(title: "Frame rate", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)

        let ntsc = UIAlertAction(title: "30 fps", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.Engine.changeFrameRate(30)
            self.frameRateButton.setTitle("30 fps", forState: .Normal)
            defaults.setValue("30", forKey: "frameRate")
        }
        alertController.addAction(ntsc)

        let pal = UIAlertAction(title: "25 fps", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.Engine.changeFrameRate(25)
            self.frameRateButton.setTitle("25 fps", forState: .Normal)
            defaults.setValue("25", forKey: "frameRate")

        }
        defaults.synchronize()
        alertController.addAction(pal)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    @IBAction func startRecord(sender: UIButton)
    {
        print("START RECORD")
        if Engine.isRecording == false {

            dispatch_async(dispatch_get_main_queue()){
                self.animateRecording()
            }

            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy_HH:mm:ss"
            let dateStr = dateFormatter.stringFromDate(date)
            let videoFileName =  dateStr + "_Forscene.mp4"
            print(videoFileName)

            guard let url = CameraEngineFileManager.documentPath(videoFileName) else {
                return
            }

            Engine.startRecordingVideo(url, blockCompletion: { (url, error) -> (Void) in
                print("url movie : \(url)")

                self.lastRecordedMovie = url!

                if self.defaults.boolForKey("saveOriginal") {

                    CameraEngineFileManager.saveVideo(url!, blockCompletion: { (success, error) -> (Void) in
                        print("ERROR SAVING VIDEO : \(error)")
                        print("VIDEO SAVED : \(success)")
                    })
                }


            })
        }
        else
        { Engine.stopRecordingVideo()
            dispatch_async(dispatch_get_main_queue()){
                self.animateStopRecording()
            }
        }
    }


    func PlayPreviewMoview (url : NSURL){

        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(ViewController.MPMoviePlayerPlaybackStateDidChange(_:)),
            name: MPMoviePlayerPlaybackStateDidChangeNotification, object: nil)

        self.moviePlayer = MPMoviePlayerViewController(contentURL: url )

        if let player = self.moviePlayer {
            player.view.frame = self.view.bounds
            // player.moviePlayer.shouldAutoplay = false
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
            let image = UIImage(named: "stop.png") as UIImage?
            self.playerStartStopButton.setImage(image, forState: .Normal)
            self.overlayBlur.alpha = 0.0
            self.playbackBlurOff()
        }
        else if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Stopped
        {
            print("stopped")
            let image = UIImage(named: "play.png") as UIImage?
            self.playerStartStopButton.setImage(image, forState: .Normal)
            self.playbackBlurOn()
        }
        else if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Paused
        {
            print("paused")
            let image = UIImage(named: "play.png") as UIImage?
            self.playerStartStopButton.setImage(image, forState: .Normal)
            self.playbackBlurOn()
        }
        else if moviePlayer?.moviePlayer.playbackState == MPMoviePlaybackState.Interrupted
        {
            print("interupted")
            let image = UIImage(named: "play.png") as UIImage?
            self.playerStartStopButton.setImage(image, forState: .Normal)
            self.playbackBlurOn()
        }
    }
    

    @IBAction func playMovie(sender: UIButton) {
        startStopMovie()
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = event!.allTouches()!.first {
            let position = touch.locationInView(self.view)
            Engine.focus(position)
        }
    }
    
    @objc func onTwoFingerPinch(recognizer: UIPinchGestureRecognizer) {
        let maxZoom: CGFloat = 6.0
        let pinchVelocityDividerFactor: CGFloat = 5.0
        if recognizer.state == .Changed {
            let desiredZoomFactor = min(maxZoom, Engine.cameraZoomFactor + atan2(recognizer.velocity, pinchVelocityDividerFactor))
            Engine.cameraZoomFactor = desiredZoomFactor
        }
    }
}

