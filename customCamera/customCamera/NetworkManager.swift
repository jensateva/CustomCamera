//
//  NetworkManager.swift
//  Captevate
//
//  Created by Jens Wikholm on 04/06/2016.
//  Copyright © 2016 Forbidden Technologies PLC. All rights reserved.
//

import Foundation
import Alamofire

public class NetworkManager: NSObject {

    public class var sharedManager:NetworkManager
    {
        struct Static
        {
            static let instance:NetworkManager = NetworkManager()
        }
        return Static.instance
    }

    let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "localhost": .PinCertificates(
            certificates: ServerTrustPolicy.certificatesInBundle(),
            validateCertificateChain: true,
            validateHost: true
        )]

    lazy var backgroundTask: Alamofire.Manager = {
        let defaults = NSUserDefaults.standardUserDefaults()
        let identifier = defaults.valueForKey("identifier") as! String
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        configuration.HTTPMaximumConnectionsPerHost = 4

        return Alamofire.Manager(configuration: configuration)

    }()
}
