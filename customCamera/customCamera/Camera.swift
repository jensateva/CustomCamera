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

    /// PUBLIC FUNCTIONS
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
           // imagePicker.mediaTypes = [kUTTypeMovie as String]
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
    //               let stringType = type as! String
    //                if stringType == kUTTypeMovie as String {
    //                    let urlOfVideo = info[UIImagePickerControllerMediaURL] as? NSURL
                        //TODO: CHECK RACE CONDITIONS
    //                    self.selectedCount += 1
    //                    self.uploadCount += 1
    //                    self.chosenImages.addObject(urlOfVideo!)
    //                    self.createProgressBars()
    
    //                    if defaults.boolForKey("uploadToProject")
    //                    {
    //                        self.UploadVideo(urlOfVideo!, destination: "project")
    //                        print("UPLOAD TO PROJECT")
    //                    }
    //                    else
    //                    {
    //                        self.UploadVideo(urlOfVideo!, destination: "mobileUploads")
    //                        print("DEFAULT UPLOAD FOLDER")
    //                    }
    //                }
                }
            }
            picker.dismissViewControllerAnimated(true, completion: nil)
        }

    
}

