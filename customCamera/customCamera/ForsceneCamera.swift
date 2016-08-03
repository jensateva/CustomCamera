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
    let settings = cameraSettings()

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
        lockFrameRate(frameRate)
        customSettings(showCustomSettings)

        settings.username = username
        settings.password = password
        settings.accountName = accountName
        settings.folder = folderName
        settings.identifier = identifier
        settings.multirecord = multirecord
        settings.framerate = frameRate
        settings.showCustomSettings = showCustomSettings
        settings.hideExitButton = hideExitButton
        settings.logo = logo

        print("username : \(settings.username)")
        print("password : \(settings.password)")
        print("account : \(settings.accountName)")
        print("folder : \(settings.folder)")
        print("identifier : \(settings.identifier)")
        print("multirecord : \(settings.multirecord)")
        print("framerate :\(settings.framerate)")
        print("showSettings :\(settings.showCustomSettings)")
        print("hideExitButton : \(settings.hideExitButton)")
        print("logo : \(settings.logo)")


        let parameters: [String: AnyObject] =
            [
                "persistentLogin":"true",
                "user": username,
                "password": password
           ]


        Alamofire.request(.POST, settings.LOGINURL, parameters: parameters, encoding: .JSON)

            .responseJSON { response in

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

                       // print(response)

                        self.settings.token = Dictionary.valueForKey("token") as! String
                        self.settings.url = Dictionary.valueForKey("urls") as! NSArray

                        let UPLOADURL = self.settings.uplodURL()
                        let HEADERS = self.settings.headers()
                        let FOLDER = self.settings.folder
                        let LOGO = self.settings.logo
                        let MULTIRECORD = self.settings.multirecord

                        print("HEADERS : \(HEADERS)")
                        print("FOLDER : \(FOLDER)")
                        print("URL : \(UPLOADURL)")
                        print("LOGO : \(LOGO)")

                        self.defaults.dictionaryForKey("HEADERS")
                        self.defaults.setValue(FOLDER, forKey: "FOLDER")
                        self.defaults.setValue(UPLOADURL, forKey: "UPLOADURL")
                        self.defaults.setValue(LOGO, forKey: "LOGO")
                        self.defaults.setBool(MULTIRECORD, forKey: "MULTIRECORD")

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
        Engine.changeFrameRate(frameRate)
    }

    private func customSettings(customControlls : Bool){
        self.defaults.setBool(customControlls, forKey: "customControlls")
    }

}

