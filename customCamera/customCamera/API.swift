//
//  API.swift
//  customCamera
//
//  Created by Jens Wikholm on 03/08/2016.
//  Copyright © 2016 Forbidden Technologies plc. All rights reserved.
//

import UIKit


class API: NSObject {

//    private func UploadVideo(urlString:NSURL)
//    {
//        print("START UPLOAD")
//        print(urlString)
//        let settings = cameraSettings()
//
//        let HEADERS = settings.headers()
//        let UPLOADURL = settings.uplodURL()
//        let FOLDER = settings.folder
//
//        print(UPLOADURL)
//        print(HEADERS)
//        print(FOLDER)
//
//        let today = NSDate.distantPast()
//        NSHTTPCookieStorage.sharedHTTPCookieStorage().removeCookiesSinceDate(today)
//
//        let task = NetworkManager.sharedManager.backgroundTask
//        task.upload(
//
//            .POST,UPLOADURL,
//            headers: HEADERS,
//            multipartFormData: { multipartFormData in
//
//                multipartFormData.appendBodyPart(fileURL: urlString, name: "uploadfile")
//                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "format")
//                multipartFormData.appendBodyPart(data: "auto".dataUsingEncoding(NSUTF8StringEncoding)!, name: "aspect")
//                multipartFormData.appendBodyPart(data: FOLDER .dataUsingEncoding(NSUTF8StringEncoding)!, name: "location")
//
//            },
//
//            encodingCompletion: { encodingResult in
//
//                switch encodingResult {
//                case .Success(let upload,  _,  _):
//
//                    upload.progress {  bytesRead, totalBytesRead, totalBytesExpectedToRead in
//
//                        print(bytesRead)
//
//                        // Show upload progress if user is multi recording
//                        dispatch_async(dispatch_get_main_queue())
//                        {
//                            self.uploadProgress.progress = (Float(totalBytesRead) / Float(totalBytesExpectedToRead))
//                        }
//                    }
//
//                    //TODO: Check Json response correctly
//                    upload.responseJSON { response in
//
//                        print("FORSCENE UPLOAD SUCCESS")
//                        self.uploadProgress.progress = 0.0
//                    }
//                case .Failure(let encodingError):
//                    
//                    print(encodingError)
//                    self.uploadProgress.progress = 0.0
//                    
//                }
//            }
//        )
//    }

}
