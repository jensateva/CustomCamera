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




    @IBOutlet weak var customSettingsContainer: UIView!
    @IBOutlet weak var focus: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var settingsIcon: UIButton!
    @IBOutlet weak var exitCameraButton: UIButton!

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

    var FRAMERATE = Int()
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
//        let bounds = UIScreen.mainScreen().bounds
//        let width = bounds.size.width
//        let height = bounds.size.height
//
//        self.settingsContainer.frame = CGRectMake(50, height / 2  - width / 2, width - 100  , width )
//        let buttonHeight = width / 6
//        self.faceDetection.frame = CGRectMake(buttonHeight, 0, self.view.frame.size.width - buttonHeight, buttonHeight)
//        self.torchMode.frame = CGRectMake(buttonHeight, buttonHeight * 1, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)
//        self.focusModeButton.frame = CGRectMake(buttonHeight, buttonHeight * 2, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)
//        self.frameRateButton.frame = CGRectMake(buttonHeight, buttonHeight * 3, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)
//        self.videoResolutionButton.frame = CGRectMake(buttonHeight, buttonHeight * 4, self.settingsContainer.frame.size.width - buttonHeight, buttonHeight)
//
//        self.iconDetection.frame = CGRectMake(0, 0, buttonHeight, buttonHeight)
//        self.iconTorch.frame = CGRectMake(0, buttonHeight, buttonHeight, buttonHeight)
//        self.iconFocus.frame = CGRectMake(0, buttonHeight * 2, buttonHeight, buttonHeight)
//        self.iconFramerate.frame = CGRectMake(0, buttonHeight * 3, buttonHeight, buttonHeight)
//        self.iconResolution.frame = CGRectMake(0, buttonHeight * 4, buttonHeight, buttonHeight)

    }


    @IBAction func changeRegion(sender: UIButton) {
        if FRAMERATE > 25
        {
            print("PAL 25")
            self.Engine.changeFrameRate(25)
            FRAMERATE = 25

            let PALIMAGE = UIImage(named: "icon_pal.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonRegion.setImage(PALIMAGE, forState: .Normal)

        }
        else
        {
            print("NTSC 30")
            self.Engine.changeFrameRate(30)
            FRAMERATE = 30

            let NTSCIMAGE = UIImage(named: "icon_ntsc.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonRegion.setImage(NTSCIMAGE, forState: .Normal)
        }
    }


    func setUpView(){

        let defaults = NSUserDefaults()
        FRAMERATE = defaults.integerForKey("frameRate")

        if FRAMERATE > 25
        {
            print(FRAMERATE)
            let ntscImage = UIImage(named: "icon_ntsc.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)

            print(ntscImage)
            self.buttonRegion.setImage(ntscImage, forState: .Normal)
            self.buttonRegion.setTitle("25", forState: .Normal)
        }
        else
        {
             print(FRAMERATE)

             let palImage = UIImage(named: "icon_pal.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)

                print(palImage)
             self.buttonRegion.setImage(palImage, forState: .Normal)
        }

        if defaults.boolForKey("showCustomSettings")
        {
            self.labelDuration.hidden = true
            self.settingsIcon.hidden = true
            
            self.customSettingsContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, 50)
            self.customSettingsContainer.hidden = false
            self.customSettingsContainer.alpha = 1.0
        }

        if defaults.boolForKey("hideExitButton")
        {
            self.labelDuration.hidden = false
            self.settingsIcon.hidden = false
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
        self.setupPortraitView()
    }

    func hideLogo(){

        UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: {

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

    @IBAction func exitCamera(sender: UIButton) {
        self.dismissViewControllerAnimated(true) {
            print("Forscene Camera Dismissed")
        }
    }

    func animateRecording(){

        let image = UIImage(named: "record_recording.png") as UIImage?
        self.recordButton.setImage(image, forState: .Normal)

        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {

            self.switchButton.alpha = 0.0
            self.settingsIcon.alpha = 0.0
            self.exitCameraButton.alpha = 0.0

            }, completion: { finished in
                self.hideCustomSettingsShowTimer()
        })
    }


    func hideCustomSettingsShowTimer(){

        self.labelDuration.alpha = 0.0
        self.labelDuration.hidden = false
        self.labelDuration.frame = CGRectMake(0, 50, self.view.frame.size.width, 50)

        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {

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

        print("Video approved")
       // print(lastRecordedMovie)

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

                    //TODO: Check Json response correctly
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


    func animateBackTorecord(){

        self.blurOff()

        let defaults = NSUserDefaults()

        if defaults.boolForKey("showCustomSettings")
        {
            self.showCustomSettingsHideTimer()
        }

        if defaults.boolForKey("hideExitButton")
        {
            self.labelDuration.hidden = false
            self.customSettingsContainer.hidden = true
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
            self.videoControlls.alpha = 1.0
            self.videoControlls.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
            self.approveButtonsVIew.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 140)
            self.approveButtonsVIew.alpha = 0.0
            }, completion: { finished in

        })

    }

    @IBAction func switchCamera(sender: AnyObject) {
        self.Engine.switchCurrentDevice()

        UIView.animateWithDuration(0.35, animations:{
           self.switchButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI));
        })
    }

    @IBAction func revealSettings(sender: UIButton) {
        blurOn()

        focus.hidden = true
        UIView.animateWithDuration(0.4, delay: 0.0, options: .CurveEaseOut, animations: {

            self.settingsView.alpha = 1.0
            self.settingsView.hidden = false
            self.videoControlls.hidden = true

            }, completion: { finished in

        })
    }

    @IBAction func hideSettings(sender: UIButton)
    {
        self.blurOff()
        self.settingsView.alpha = 0.0
        self.settingsView.hidden = true
        self.videoControlls.hidden = false
        focus.hidden = false
    }

    @IBAction func changeQuallity(sender: AnyObject) {

        if self.Engine.videoEncoderPresset == CameraEngineVideoEncoderEncoderSettings.Preset1280x720
        {
            self.Engine.videoEncoderPresset = CameraEngineVideoEncoderEncoderSettings.Preset1920x1080

   let buttonImage = UIImage(named: "icon_hd.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)

            self.buttonQuallity.setImage(buttonImage, forState: .Normal)
        }
        else  if self.Engine.videoEncoderPresset == CameraEngineVideoEncoderEncoderSettings.Preset1920x1080
        {
            self.Engine.videoEncoderPresset = CameraEngineVideoEncoderEncoderSettings.Preset3840x2160

   let buttonImage = UIImage(named: "icon_4k.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)


            self.buttonQuallity.setImage(buttonImage, forState: .Normal)
        }
        else
        {
        self.Engine.videoEncoderPresset = CameraEngineVideoEncoderEncoderSettings.Preset1280x720
   let buttonImage = UIImage(named: "icon_sd.png", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)

            self.buttonQuallity.setImage(buttonImage, forState: .Normal)
        }

        print("Video Resolution is: :\(self.Engine.videoEncoderPresset)")
    }





    @IBAction func changeFocusmode(sender: UIButton) {

        if self.Engine.cameraFocus == CameraEngineCameraFocus.AutoFocus
        {
            Engine.cameraFocus = CameraEngineCameraFocus.ContinuousAutoFocus

             let image = UIImage(named: "icon_focus_continious", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonFocusmode.setImage(image, forState: .Normal)

        }
         else if self.Engine.cameraFocus == CameraEngineCameraFocus.ContinuousAutoFocus
        {
            Engine.cameraFocus = CameraEngineCameraFocus.ContinuousAutoFocus

            let image = UIImage(named: "icon_focus_auto", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonFocusmode.setImage(image, forState: .Normal)

        }

          else if self.Engine.cameraFocus == CameraEngineCameraFocus.Locked
        {

            Engine.cameraFocus = CameraEngineCameraFocus.AutoFocus

            let image = UIImage(named: "icon_focus_locked", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonFocusmode.setImage(image, forState: .Normal)

        }

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

        if self.Engine.torchMode ==  AVCaptureTorchMode.Off
        {
            self.Engine.torchMode = .On
            let torchImage = UIImage(named: "icon_flash_on", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonTorchmode.setImage(torchImage, forState: .Normal)
        }

        else if self.Engine.torchMode ==  AVCaptureTorchMode.On
        {
            self.Engine.torchMode = .Auto
            let torchImage = UIImage(named: "icon_flash_auto", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonTorchmode.setImage(torchImage, forState: .Normal)
        }
        else
        {


            self.Engine.torchMode = .Off
            let torchImage = UIImage(named: "icon_flash_off", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
            self.buttonTorchmode.setImage(torchImage, forState: .Normal)
            
        }
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

                print(focusCompatible)
                print(currentFocusMode)

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
            // print(videoFileName)

            guard let url = CameraEngineFileManager.documentPath(videoFileName) else {
                return
            }

            Engine.startRecordingVideo(url, blockCompletion: { (url, error) -> (Void) in
               // print("url movie : \(url)")

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
}

