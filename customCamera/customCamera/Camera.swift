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

public class Camera : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

     let defaults = NSUserDefaults.standardUserDefaults()


    public func openCamera(targetVC: UIViewController){
        print("Calling open camera")
        let cameraView = CameraViewController()
        dispatch_async(dispatch_get_main_queue(), {
        targetVC.presentViewController(cameraView, animated: true, completion: nil)
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

           // forsceneConnect()
        }


        public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let mediaType:AnyObject? = info[UIImagePickerControllerMediaType]
    
            if let type:AnyObject = mediaType {
                if type is String {
                   let stringType = type as! String
                    if stringType == kUTTypeMovie as String {

                        let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                        print(urlOfVideo)
                         // self.UploadVideo(urlOfVideo!)
                         // self.forsceneConnect()

                        self.UploadVideo(urlOfVideo!)

                    }
                }
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
        }


    public func connectToForscene()
    {
        print("CONNECTING TO FORSCENE")
        let LOGIN_URL = "https://forscene.net/api/login"
        let username = Account.Constants.FORSCENE_USERID as String
        let password = Account.Constants.FORSCENE_PASSWORD as String

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
                    print("Success with JSON: \(JSON)")

                    let Dictionary = JSON .valueForKey("results") as! NSDictionary
                    let status = Dictionary .valueForKey("status") as! String

                    switch status
                    {
                    case ("valid"):

                        let token = Dictionary .valueForKey("token")
                        //  let persistentToken = Dictionary .valueForKey("persistentToken")
                        // let urls = Dictionary .valueForKey("urls")
                        // self.defaults.setObject(persistentToken, forKey: "persistentToken")
                        self.defaults.setObject(token, forKey: "token")
                        //  self.defaults.setObject(urls, forKey: "urls")
                        self.defaults.setBool(true, forKey: "Registered")
                        self.defaults.synchronize()

                    case ("invalid"):
                        print("invalid")

                    default:
                        print("Default switch")
                    }
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }









    public func forsceneConnect(username:String, password:String)
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
                    print("Success with JSON: \(JSON)")

                    let Dictionary = JSON .valueForKey("results") as! NSDictionary
                    let status = Dictionary .valueForKey("status") as! String

                    switch status
                    {
                    case ("valid"):

                        let token = Dictionary .valueForKey("token")
                       //  let persistentToken = Dictionary .valueForKey("persistentToken")
                       // let urls = Dictionary .valueForKey("urls")
                       // self.defaults.setObject(persistentToken, forKey: "persistentToken")
                        self.defaults.setObject(token, forKey: "token")
                      //  self.defaults.setObject(urls, forKey: "urls")
                        self.defaults.setBool(true, forKey: "Registered")
                        self.defaults.synchronize()

                    case ("invalid"):
                        print("invalid")

                    default:
                        print("Default switch")
                    }

                case .Failure(let error):
                    print("Request failed with error: \(error)")
                }
        }
    }






    private func UploadVideo(urlString:NSURL)
    {
        let TOKEN = defaults.valueForKey("token")
        let headers = ["X-Auth-Kestrel": TOKEN as! String ]

        let today = NSDate.distantPast()
        NSHTTPCookieStorage.sharedHTTPCookieStorage().removeCookiesSinceDate(today)

        let FORSCENE_UPLOADURL = "https://pro.forscene.net/forscene/" + Account.Constants.FORSCENE_ACCOUNTNAME + "/webupload?resultFormat=json" as String

        let task = NetworkManager.sharedManager.backgroundTask
        let folder = Account.Constants.FORSCENE_FOLDER as String

        task.upload(

            .POST,FORSCENE_UPLOADURL,
            headers: headers,
            multipartFormData: { multipartFormData in

                multipartFormData.appendBodyPart(fileURL: urlString, name: "uploadfile")
                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "format")
                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "aspect")
                multipartFormData.appendBodyPart(data: folder .dataUsingEncoding(NSUTF8StringEncoding)!, name: "location")

            },

            encodingCompletion: { encodingResult in

                switch encodingResult {

                case .Success(let upload,  _,  _):

                    upload.progress {  bytesRead, totalBytesRead, totalBytesExpectedToRead in

                        print(bytesRead)

//                        dispatch_async(dispatch_get_main_queue())
//                        {
//                            self.fileMetaDataDictionary[urlString]?.progressBar.angle = (Double(totalBytesRead) / Double(totalBytesExpectedToRead)) * (self.fileMetaDataDictionary[urlString]?.fileProportionalAngle)!
//                        }
                    }

                    //TODO: Check Json response correctly
                    upload.responseJSON { response in

                        print("UPLOAD SUCCESS")
                    }
                case .Failure(let encodingError):

                    print(encodingError)

                }
            }
        )
    }


    
}

