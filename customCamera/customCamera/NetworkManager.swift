//
//  NetworkManager.swift
//  Captevate
//
//  Created by Jens Wikholm on 04/06/2016.
//  Copyright © 2016 Forbidden Technologies PLC. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager: NSObject {

    class var sharedManager:NetworkManager
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
        let identifier = Account.Constants.FORSCENE_BACKGROUND_IDENTIFIER

        // NEW
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        configuration.HTTPMaximumConnectionsPerHost = 4
        print(configuration.identifier)


        // configuration.timeoutIntervalForRequest = 120
        return Alamofire.Manager(configuration: configuration)

        // ORIGINAL USE THIS AGAIN LATER WHEN WE HAVE UI TO SHOW MULTI UPLOAD WORKING AT SAME TIME
        // return Alamofire.Manager(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier))
    }()
}
