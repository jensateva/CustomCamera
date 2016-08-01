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

public class ForsceneCamera : UIViewController, UINavigationControllerDelegate {

    let defaults = NSUserDefaults.standardUserDefaults()
    let Engine = CameraEngine()
    var currentView = UIViewController()

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

    public func openCustomCamera(targetVC: UIViewController, animated:Bool){

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


    public func connectToForscene(username: String, password: String, accountName: String, folderName: String, identifier: String, multirecord: Bool, frameRate : Int32, showCustomSettings : Bool, hideExitButton : Bool, logo : String)
    {
        if frameRate > 23
        {
        lockFrameRate(frameRate)
        }
        customSettings(showCustomSettings)
        print("CONNECTING TO FORSCENE")
        let LOGIN_URL = "https://forscene.net/api/login"

        let parameters: [String: AnyObject] =
            [
                "persistentLogin":"true",
                "user": username,
                "password": password
        ]

        Alamofire.request(.POST, LOGIN_URL, parameters: parameters, encoding: .JSON)

            .responseJSON { response in
               // debugPrint(response)

                switch response.result
                {
                case .Success(let JSON):
                    print("CONNECTING TO FORSCENE...")

                    let Dictionary = JSON .valueForKey("results") as! NSDictionary
                    let status = Dictionary .valueForKey("status") as! String

                    switch status
                    {
                    case ("valid"):

                        print("CONNECTED WITH SUCCESS!")
                        let token = Dictionary .valueForKey("token")
                        self.defaults.setObject(token, forKey: "token")
                        self.defaults.setBool(true, forKey: "Registered")
                        self.defaults.setValue(accountName, forKey: "accountName")
                        self.defaults.setValue(folderName, forKey: "folderName")
                        self.defaults.setValue(identifier, forKey: "identifier")
                        self.defaults.setBool(multirecord, forKey: "multirecord")
                        self.defaults.setBool(showCustomSettings, forKey: "showCustomSettings")
                        self.defaults.setBool(hideExitButton, forKey: "hideExitButton")
                        self.defaults.setValue(logo, forKeyPath: "logo")
                        self.defaults.synchronize()

                    case ("invalid"):
                        print("INVALID CREDENTIALS")

                    default:
                        print("Default switch")
                    }
                    
                case .Failure(let error):
                    print("REQUEST FAILED WITH ERROR: \(error)")
                }
        }
    }

    private func lockFrameRate(frameRate : Int32){
        print("SETTING FRAMERATE : \(frameRate)")
        Engine.changeFrameRate(frameRate)
    }

    private func customSettings(customControlls : Bool){
        print("SHOW CUSTOM SETTING : \(customControlls)")
        self.defaults.setBool(customControlls, forKey: "customControlls")
    }

}

