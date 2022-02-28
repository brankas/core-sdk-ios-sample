//
//  ViewController.swift
//  TestApp
//
//  Created by Ejay Torres on 11/25/20.
//

import UIKit
import StatementTapFramework

class ViewController: UIViewController, CheckDelegate {
    typealias T = String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if Constants.API_KEY.isEmpty {
            print("API Key must not be empty. Please provide the API Key located in Constants Class")
            return
        }
        
        StatementTapSF.shared.initialize(apiKey: Constants.API_KEY, certPath: nil, isDebug: false)

        let request = StatementTapRequest(country: Country.PH, bankCodes: [BankCode.BDO], externalId: "External ID", successURL: "https://google.com", failURL: "https://hello.com", organizationName: "Organization Name", redirectDuration: 60, browserMode: StatementTapRequest.BrowserMode.WebView, dismissAlert: nil, useRememberMe: false)

        do {
            let retrieveStatements = { (data: Any?, error: String?) in
                if let str = data as? String {
                    if let err = error {
                        print("Statement ID: \(str)\nError: \(err)")
                    }
                    else {
                        print("Statement ID: \(str)")
                    }
                }
                
                else if let statements = data as? [Statement] {
                    var message = "Statements"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                    
                    if statements.isEmpty {
                        message += "\n\n\nList is Empty"
                    }
                    statements.forEach { statement in
                        statement.transactions.forEach { transaction in
                            let amount = transaction.amount
                            message += "\n Account: \(statement.account.holderName)"
                            message += "\n Transaction: (\(dateFormatter.string(from: transaction.date))) "
                            message += String(describing: amount.currency)
                            message += " \(Double(amount.numInCents) ?? 0 / 100)"
                            message += " \(String(describing: transaction.type))"
                        }
                    }
                   print(message)
                }
                
                else {
                    if let err = error {
                        print("ERROR: \(err)")
                    }
                }
            }
            try StatementTapSF.shared.checkout(statementTapRequest: request, vc: self, closure: retrieveStatements, showBackButton: false)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func hasCheckError() {
        print("HAS ERROR GOTTEN")
    }
}
