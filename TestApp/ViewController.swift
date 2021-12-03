//
//  ViewController.swift
//  TestApp
//
//  Created by Ejay Torres on 11/25/20.
//

import UIKit
import StatementTapFramework

class ViewController: UIViewController, CoreDelegate, CheckDelegate {
    typealias T = String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if Constants.API_KEY.isEmpty {
            print("API Key must not be empty. Please provide the API Key located in Constants Class")
            return
        }
        
        StatementTapSF.shared.initialize(apiKey: Constants.API_KEY, certPath: nil, isDebug: false)

        let request = StatementTapRequest(country: Country.PH, bankCodes: [BankCode.BDO], externalId: "External ID", successURL: "https://google.com", failURL: "https://hello.com", organizationName: "Organization Name", redirectDuration: 60, browserMode: StatementTapRequest.BrowserMode.WebView, dismissAlert: nil, useRememberMe: true)

        do {
            try StatementTapSF.shared.checkout(statementTapRequest: request, vc: self, delegate: self, showBackButton: false)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func onResult(data: String?, error: String?, errorCode: String?) {
        if let str = data {
            print("STATEMENT ID: \(str)")
        }
        
        if let err = error {
            print("Error Logs: \(err)")
        }
    }
    
    func hasCheckError() {
        print("HAS ERROR GOTTEN")
    }
}
