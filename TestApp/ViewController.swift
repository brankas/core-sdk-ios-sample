//
//  ViewController.swift
//  TestApp
//
//  Created by Ejay Torres on 11/25/20.
//

import UIKit
import DirectTapFramework

class ViewController: UIViewController, CoreDelegate, CheckDelegate {
    typealias T = String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if Constants.API_KEY.isEmpty {
            print("API Key must not be empty. Please provide the API Key located in Constants Class")
            return
        }
        
        DirectTapSF.shared.initialize(apiKey: Constants.API_KEY, certPath: nil, isDebug: false)

        let account = Account(country: Country.PH)
        let amount = Amount(currency: Currency.php, numInCents: "10000")
        let customer = Customer(firstName: "First", lastName: "Last", email: "hello@gmail.com", mobileNumber: "63")
        var client = Client()
        client.displayName = "Display Name"
        client.returnUrl = "https://www.google.com.ph"
        
        var components = DateComponents()
        components.hour = 16
        components.minute = 00
        components.month = 12
        components.day = 6
        components.year = 2021
        
        let date = Calendar.current.date(from: components)

        var request = DirectTapRequest(sourceAccount: account, destinationAccountId: Constants.DESTINATION_ACCOUNT_ID, amount: amount, memo: "Bank Transfer", customer: customer, referenceId: "sample-reference754878", client: client, dismissAlert: DismissAlert(message: "Do you want to close the application?", confirmButtonText: "Yes", cancelButtonText: "Cancel"), expiryDate: date)

        request.browserMode = DirectTapRequest.BrowserMode.WebView
        request.useRememberMe = true

        do {
            try DirectTapSF.shared.checkout(tapRequest: request, vc: self, delegate: self, showBackButton: false)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func onResult(data: String?, error: String?, errorCode: String?) {
        print("RESULT: \(data) \(error) \(errorCode)")
        if let str = data {
            print("TRANSACTION ID: \(str)")
        }
        
        if let err = error {
            if let errCode = errorCode {
                print("Error Logs: \(err) \(errCode)")
            }
            else {
                print("Error Logs: \(err)")
            }
        }
    }
    
    func hasCheckError() {
        print("HAS ERROR GOTTEN")
    }
}
