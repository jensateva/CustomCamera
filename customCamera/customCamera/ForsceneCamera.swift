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

public class ForsceneCamera : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let defaults = NSUserDefaults.standardUserDefaults()

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

    public func openCustomCamera(targetVC: UIViewController, frameRate : Int32){

        // Find the storyboard
        let storyboardName = "Custom"
        let storyboardBundle = NSBundle(forClass: ForsceneCamera.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)

        // Find the VC
        let vc = storyboard.instantiateViewControllerWithIdentifier("ViewController")
        dispatch_async(dispatch_get_main_queue(), {
            targetVC.presentViewController(vc, animated: true, completion: nil)
        })
    }

        public func openPickerCamera(targetVC: UIViewController){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .Camera
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.delegate = self
            imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeHigh
    
            dispatch_async(dispatch_get_main_queue(), {
                targetVC.presentViewController(imagePicker, animated: true, completion: nil)
            })
        }


        public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
    
            if let type:AnyObject = mediaType {
                if type is String {
                   let stringType = type as! String
                    if stringType == kUTTypeMovie as String {

                        let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                        self.UploadVideo(urlOfVideo!)

                    }
                }
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
        }


    public func connectToForscene(username: String, password: String, accountName: String, folderName: String, identifier: String)
    {
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
                debugPrint(response)

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





    public func UploadVideo(urlString:NSURL)
    {
        let TOKEN = defaults.valueForKey("token")
        let headers = ["X-Auth-Kestrel": TOKEN as! String ]
        let today = NSDate.distantPast()
        NSHTTPCookieStorage.sharedHTTPCookieStorage().removeCookiesSinceDate(today)

        let accountName = defaults.valueForKey("accountName") as! String
        let folderName = defaults.valueForKey("folderName") as! String
        let uploadUrl = "https://pro.forscene.net/forscene/" + accountName + "/webupload?resultFormat=json" as String

        let task = NetworkManager.sharedManager.backgroundTask
        task.upload(

            .POST,uploadUrl,
            headers: headers,
            multipartFormData: { multipartFormData in

                multipartFormData.appendBodyPart(fileURL: urlString, name: "uploadfile")
                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "format")
                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "aspect")
                multipartFormData.appendBodyPart(data: folderName .dataUsingEncoding(NSUTF8StringEncoding)!, name: "location")

            },

            encodingCompletion: { encodingResult in

                switch encodingResult {
                case .Success(let upload,  _,  _):

                    upload.progress {  bytesRead, totalBytesRead, totalBytesExpectedToRead in

                        print(bytesRead)

                        // Not Tested
                        dispatch_async(dispatch_get_main_queue())
                        {
                            let progressBar = UIProgressView()
                            progressBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 2)
                            self.view.addSubview(progressBar)
                            progressBar.progress = (Float(totalBytesRead) / Float(totalBytesExpectedToRead))
                        }
                    }

                    //TODO: Check Json response correctly
                    upload.responseJSON { response in

                        print("FORSCENE UPLOAD SUCCESS")
                    }
                case .Failure(let encodingError):

                    print(encodingError)

                }
            }
        )
    }


    
}

