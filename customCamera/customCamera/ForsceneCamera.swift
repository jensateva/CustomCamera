//
//  Camera.swift
//  customCamera
//
//  Created by Jens Wikholm on 25/07/2016.
//  Copyright © 2016 Video Clips Ltd. All rights reserved.
//

//
//  ForbiddenCamera.swift
//  ForbiddenCamera
//
//  Created by Jens Wikholm on 25/07/2016.
//  Copyright © 2016 Forbidden Technologies PLC. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit
import Alamofire

var currentView = UIViewController()

public class ForsceneCamera : UIViewController, UINavigationControllerDelegate {

    let defaults = NSUserDefaults.standardUserDefaults()
    let Engine = CameraEngine()
       let LOGINURL = "https://forscene.net/api/login"
    var uploadProgress = Float()

    required convenience public init(coder aDecoder: NSCoder) {
        self.init(aDecoder)
    }

    public init(_ coder: NSCoder? = nil) {
        if let coder = coder {
            super.init(coder: coder)!
        }
        else {
            super.init(nibName: nil, bundle:nil)
        }
    }

    public func launchCamera(targetVC: UIViewController, animated:Bool){

        currentView = targetVC
        // Find the storyboard
        let storyboardName = "Custom"
        let storyboardBundle = NSBundle(forClass: ForsceneCamera.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)

        // Find the VC
        let vc = storyboard.instantiateViewControllerWithIdentifier("ForsceneCamera")
        dispatch_async(dispatch_get_main_queue(), {
            targetVC.presentViewController(vc, animated: animated, completion: nil)
        })
    }



    public func setUpCamera(folderName: String, identifier: String, multirecord: Bool, frameRate : Int, showCustomSettings : Bool, hideExitButton : Bool, logo : String, saveOriginal : Bool, uploadVideo : Bool)
    {
        lockFrameRate(frameRate)
        self.defaults.setValue(identifier, forKey: "identifier")
        self.defaults.setValue(folderName, forKey: "folderName")
        self.defaults.setBool(multirecord, forKey: "multirecord")
        self.defaults.setInteger(frameRate, forKey: "frameRate")
        self.defaults.setValue(showCustomSettings, forKey: "showCustomSettings")
        self.defaults.setBool(hideExitButton, forKey: "hideExitButton")
        self.defaults.setValue(logo, forKey: "logo")
        self.defaults.setBool(showCustomSettings, forKey: "showCustomSettings")
        self.defaults.setBool(saveOriginal, forKey: "saveOriginal")
        self.defaults.setBool(uploadVideo, forKey: "uploadVideo")
        defaults.synchronize()
        lockFrameRate(frameRate)

//        print("App Identifier :\(defaults.valueForKey:"identifier")")
//        print("Destination Foler :\(defaults.valueForKey:"folderName")")

    }

    public func GetUploadProgress() -> Float
    {
        return uploadProgress
    }

    public func connectToForscene(username: String, password: String, accountName: String)
    {
        let parameters: [String: AnyObject] =
            [
                "persistentLogin":"true",
                "user": username,
                "password": password
        ]


        Alamofire.request(.POST, LOGINURL, parameters: parameters, encoding: .JSON)

            .responseJSON { response in

                switch response.result
                {
                case .Success(let JSON):
                    print("Connecting to Forscene...")

                    let Dictionary = JSON .valueForKey("results") as! NSDictionary
                    let status = Dictionary .valueForKey("status") as! String

                    switch status
                    {
                    case ("valid"):

                        print("Connected with success!")

                        let url = Dictionary.valueForKey("urls") as! NSArray

                       // https://pro.forscene.net
                        let uploadurl = "https://pro.forscene.net/" + accountName + "/webupload?resultFormat=json"
                        //let uploadurl = (url[0]).stringByDeletingLastPathComponent + "/" + accountName + "/webupload?resultFormat=json"
                        let token = Dictionary.valueForKey("token")

                        self.defaults.setValue(uploadurl, forKey: "uploadurl")
                        self.defaults.setValue(token, forKey: "token")
                        self.defaults.synchronize()

                        print(uploadurl)


                    case ("invalid"):
                        print("Iinvalid credentials")

                    default:
                        print("Default switch")
                    }

                case .Failure(let error):
                    print("Failed with error: \(error)")
                }
        }
    }
    
    private func lockFrameRate(frameRate : Int){
        let frameRateInt32 = Int32(frameRate)
        Engine.changeFrameRate(frameRateInt32)
    }
    
    private func customSettings(customControlls : Bool){
        self.defaults.setBool(customControlls, forKey: "customControlls")
    }
    
}

