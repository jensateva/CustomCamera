//
//  RemoteNotificationDeepLink.swift
//  Testing Frameworks
//
//  Created by Jens Wikholm on 02/08/2016.
//  Copyright © 2016 Forbidden Technologies PLC. All rights reserved.
//

import UIKit

let RemoteNotificationDeepLinkAppSectionKey : String = "article"

class RemoteNotificationDeepLink: NSObject {

    var tag : String = ""

    class func create(userInfo : [NSObject : AnyObject]) -> RemoteNotificationDeepLink?
    {
        let info = userInfo as NSDictionary

        var tagID = info.objectForKey(RemoteNotificationDeepLinkAppSectionKey) as! String

        var ret : RemoteNotificationDeepLink? = nil
        if !tagID.isEmpty
        {
            ret = RemoteNotificationDeepLinkArticle(tagStr: tagID)
        }
        return ret
    }

    private override init()
    {
        self.tag = ""
        super.init()
    }

    private init(tagStr: String)
    {
        self.tag = tagStr
        super.init()
    }

    final func trigger()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            NSLog("Triggering Deep Link - %@", self)
            self.triggerImp()
                { (passedData) in
                   print(passedData)
            }
        }
}

    private func triggerImp(completion: ((AnyObject?)->(Void)))
    {

        completion(nil)
    }
}


class RemoteNotificationDeepLinkArticle : RemoteNotificationDeepLink
{
    var tagID : String!
    override init(tagStr: String)
    {
        self.tagID = tagStr
        super.init(tagStr: tagStr)
    }

    private override func triggerImp(completion: ((AnyObject?)->(Void)))
    {
        super.triggerImp()
            { (passedData) in

                var vc = UIViewController()
                print("LAUNCH CAMERA WITH TAG \(self.tagID)")

                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.addSubview(vc.view)

                completion(nil)
        }
    }

}