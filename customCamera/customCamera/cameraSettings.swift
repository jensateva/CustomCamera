//
//  cameraSettings.swift
//  customCamera
//
//  Created by Jens Wikholm on 03/08/2016.
//  Copyright © 2016 Forbidden Technologies plc. All rights reserved.
//

import UIKit

class cameraSettings: NSObject {

    let LOGINURL = "https://forscene.net/api/login"

    // SET BY USER
    var username: String = ""
    var password: String = ""
    var accountName: String = ""
    var folder: String = "App"
    var identifier: String = ""
    var multirecord: Bool = false
    var framerate: Int32 = 30
    var showCustomSettings: Bool = false
    var hideExitButton: Bool = false
    var logo: String = ""


    // OTHER SETTINGS
    var saveOriginal: Bool = false
    var brandColour : UIColor = UIColor.blackColor()

    // SET FROM LOGIN RESPONCE
    var url : NSArray = []
    var token : String = ""

    func uplodURL() -> String{
    let UPLOADURL = (url[0]).stringByDeletingLastPathComponent + "/" + accountName + "/webupload?resultFormat=json"
    return UPLOADURL
    }

    func headers() -> [String : String]{
       let headers = ["X-Auth-Kesterl" : token]
        return headers
    }


}