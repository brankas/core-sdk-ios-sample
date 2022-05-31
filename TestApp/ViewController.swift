//
//  ViewController.swift
//  TestApp
//
//  Created by Ejay Torres on 11/25/20.
//

import UIKit
import StatementTapFramework
import SDWebImageSVGCoder
import SDWebImage
import RxSwift
import RxCocoa

class ViewController: UIViewController, CheckDelegate {
    typealias T = String
    
    private var countryCode: Country = Country.PH
    private var banks: [StatementBank] = []
    private var bankSelections: [CheckboxButton] = []
    private var startDate = Date.yesterday
    private var endDate = Date()

    private var subscribers: [Disposable] = []

    @IBOutlet weak var tfOrganizationName: UITextField!
    @IBOutlet weak var tfExternalId: UITextField!
    @IBOutlet weak var tfSuccessURL: UITextField!
    @IBOutlet weak var tfFailURL: UITextField!
    @IBOutlet weak var swUseRememberMe: UISwitch! //false
    @IBOutlet weak var swAutoConsent: UISwitch! //false
    @IBOutlet weak var swBackButton: UISwitch! // true
    @IBOutlet weak var swRetrieveStatements: UISwitch! //false
    @IBOutlet weak var tfCountry: UITextField!
    @IBOutlet weak var vPersonalBanks: UIView!
    @IBOutlet weak var stPersonalBanks: UIStackView!
    @IBOutlet weak var vCorporateBanks: UIView!
    @IBOutlet weak var stCorporateBanks: UIStackView!
    @IBOutlet weak var vStartDate: UIView!
    @IBOutlet weak var tfStartDate: UITextField!
    @IBOutlet weak var vEndDate: UIView!
    @IBOutlet weak var tfEndDate: UITextField!
    @IBOutlet weak var btCheckout: UIButton!
    @IBOutlet weak var vProgressing: UIView!

    @IBAction func onAutoFillDetails(_ sender: Any) {
        tfOrganizationName.text = "Sample Org"
        tfExternalId.text = "External ID"
        tfSuccessURL.text = "https://google.com"
        tfFailURL.text = "https://hello.com"

        tfOrganizationName.sendActions(for: .editingChanged)
        tfExternalId.sendActions(for: .editingChanged)
        tfSuccessURL.sendActions(for: .editingChanged)
        tfFailURL.sendActions(for: .editingChanged)
    }

    @IBAction func onStatementRetrieval(_ sender: Any) {
        vStartDate.isHidden = !swRetrieveStatements.isOn
        vEndDate.isHidden = !swRetrieveStatements.isOn
    }

    @IBAction func onCheckout(_ sender: Any) {
        if !checkAPIKey() {return}

        vProgressing.isHidden = false

        var request = StatementTapRequest(country: countryCode, bankCodes: getCheckedBankCodes(), externalId: tfExternalId.text ?? "", successURL: tfSuccessURL.text ?? "", failURL: tfFailURL.text ?? "", organizationName: tfOrganizationName.text ?? "", redirectDuration: 60, browserMode: .WebView, dismissAlert: nil, isAutoConsent: swAutoConsent.isOn, useRememberMe: swUseRememberMe.isOn)

        if swRetrieveStatements.isOn {
            request.statementRetrievalRequest = StatementRetrievalRequest(startDate: startDate, endDate: endDate)
        }

        StatementTapSF.shared.initialize(apiKey: Constants.API_KEY, certPath: nil, isDebug: false)

        do {
            try StatementTapSF.shared.checkout(statementTapRequest: request, vc: self, closure: { data, err in
                self.setResult(data: data, error: err)
            }, showBackButton: swBackButton.isOn)
        } catch {
            showAlert(message: "Error: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)

        vStartDate.isHidden = true
        vEndDate.isHidden = true
        vPersonalBanks.isHidden = true
        vCorporateBanks.isHidden = true

        let countryPicker = UIPickerView()
        countryPicker.delegate = self
        countryPicker.tag = 1
        tfCountry.inputView = countryPicker

        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
        }
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        tfStartDate.inputView = startDatePicker

        let endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            endDatePicker.preferredDatePickerStyle = .wheels
        }
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        tfEndDate.inputView = endDatePicker

        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        tfStartDate.text = df.string(from: startDate)
        tfEndDate.text = df.string(from: endDate)

        getEnabledBanks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribers.append(Observable.combineLatest(
            tfOrganizationName.rx.controlEvent(.editingChanged),
            tfExternalId.rx.controlEvent(.editingChanged),
            tfSuccessURL.rx.controlEvent(.editingChanged),
            tfFailURL.rx.controlEvent(.editingChanged)
        ).subscribe(onNext: { _ in
            self.formValidation()
        }))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        subscribers.forEach { $0.dispose() }
        subscribers.removeAll()
    }

    @objc func startDateChanged(datePicker: UIDatePicker) {
        let date = datePicker.date
        startDate = date

        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        tfStartDate.text = df.string(from: date)
    }

    @objc func endDateChanged(datePicker: UIDatePicker) {
        let date = datePicker.date
        endDate = date

        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        tfEndDate.text = df.string(from: date)
    }

    func hasCheckError() {
        print("HAS ERROR GOTTEN")
    }

    private func checkAPIKey() -> Bool {
        if Constants.API_KEY.isEmpty {
            showAlert(message: "API Key must not be empty. Please provide the API Key located in Constants Class")
            return false
        } else {
            return true
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        }))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.present(alert, animated: true, completion: nil)
            self.vProgressing.isHidden = true
        }
    }

    private func formValidation() {
        guard let orgName = self.tfOrganizationName.text, !orgName.isEmpty,
              let externalId = self.tfExternalId.text, !externalId.isEmpty,
              let successURL = self.tfSuccessURL.text, !successURL.isEmpty,
              let failURL = self.tfFailURL.text, !failURL.isEmpty
        else {
            self.btCheckout.isEnabled = false
            self.btCheckout.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
            return
        }

        if (!successURL.hasPrefix("http://") && !successURL.hasPrefix("https://") && !successURL.hasPrefix("www."))
            || (!failURL.hasPrefix("http://") && !failURL.hasPrefix("https://") && !failURL.hasPrefix("www."))
        {
            self.btCheckout.isEnabled = false
            self.btCheckout.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
            return
        }

        self.btCheckout.isEnabled = true
        self.btCheckout.backgroundColor = UIColor(red: 146/255, green: 88/255, blue: 225/255, alpha: 1)
    }

    private func getEnabledBanks() {
        if !checkAPIKey() {return}

        vProgressing.isHidden = false
        
        StatementTapSF.shared.initialize(apiKey: Constants.API_KEY, certPath: nil, isDebug: false)
        StatementTapSF.shared.getEnabledBanks(country: countryCode) { data, err in
            self.vProgressing.isHidden = true

            if data.isEmpty {
                self.showAlert(message: err ?? "Fetching banks failed")
                return
            }

            self.bankSelections.removeAll()
            self.banks.removeAll()
            self.banks.append(contentsOf: data.filter { !$0.isCorporate })

            if 1 > self.banks.count {
                self.vPersonalBanks.isHidden = true
            } else {
                self.vPersonalBanks.isHidden = false
                self.setupBanks(stackView: self.stPersonalBanks, banks: self.banks)
            }

            let corporateBanks = data.filter { $0.isCorporate }

            if 1 > corporateBanks.count {
                self.vCorporateBanks.isHidden = true
            } else {
                self.vCorporateBanks.isHidden = false
                self.setupBanks(stackView: self.stCorporateBanks, banks: corporateBanks)
                self.banks.append(contentsOf: corporateBanks)
            }


        }

    }

    private func setupBanks(stackView: UIStackView, banks: [StatementBank]) {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        banks.forEach {
            let width = stackView.bounds.width
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))

            let check = CheckboxButton(frame: CGRect(x: 0, y: 15, width: 20, height: 20))
            check.checkColor = UIColor(red: 146/255, green: 88/255, blue: 225/255, alpha: 1)
            check.containerColor = UIColor(red: 146/255, green: 88/255, blue: 225/255, alpha: 1)
            check.on = true
            bankSelections.append(check)
            view.addSubview(check)

            let label = UILabel(frame: CGRect(x: 30, y: 0, width: width - 70, height: 50 ))
            label.font = UIFont(name: "Ubuntu-Regular", size: 14)
            label.text = $0.title
            view.addSubview(label)

            let imageView = UIImageView(frame: CGRect(x: width - 40, y: 10, width: 30, height: 30))
            imageView.contentMode = .scaleAspectFit
            imageView.sd_setImage(with: URL(string: $0.logoUrl), placeholderImage: UIImage(named: "ic_banking"))
            view.addSubview(imageView)

            stackView.addArrangedSubview(view)

            let constraints = [
                view.heightAnchor.constraint(equalToConstant: 50)
            ]
            NSLayoutConstraint.activate(constraints)
        }

    }

    private func getCheckedBankCodes() -> [StatementBankCode] {
        var list: [StatementBankCode] = []

        for (index, check) in bankSelections.enumerated() {
            if check.on {
                list.append(banks[index].bankCode)
            }
        }

        return list
    }

    private func setResult(data: Any?, error: String?) {
        if let str = data as? String {
            if let err = error {
                showAlert(message: "Statement ID: \(str)\nError: \(err)")
            }
            else {
                showStatementList(statementId: str, message: "")
            }
        } else if let statements = data as? [Statement] {
            if statements.isEmpty {
                showAlert(message: "Statement List\n\n\nList is Empty")
                return
            }

            var statementId = ""
            var message = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"

            statements.forEach { statement in
                statementId = statement.id
                statement.transactions.forEach { transaction in
                    let amount = transaction.amount
                    message += "\n Account: \(statement.account.holderName)"
                    message += "\n Transaction: (\(dateFormatter.string(from: transaction.date))) "
                    message += String(describing: amount.currency)
                    message += " \(Double(amount.numInCents) ?? 0 / 100)"
                    message += " \(String(describing: transaction.type))"
                }
            }

            showStatementList(statementId: statementId, message: message)
        } else {
            if let err = error {
                showAlert(message: "Error: \(err)")
            }
        }
    }

    private func showStatementList(statementId: String, message: String) {
        let alert = UIAlertController(title: "Statement List", message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Download Statement", style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)

            self.vProgressing.isHidden = false
            StatementTapSF.shared.downloadStatement(vc: self, statementId: statementId, closure: { data, err in
                if nil == err {
                    self.showAlert(message: "Download successful")
                } else {
                    self.showAlert(message: err ?? "Download failed")
                }
            }, enableSaving: true)
        }))

        alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        }))

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.present(alert, animated: true, completion: nil)
            self.vProgressing.isHidden = true
        }
    }

}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            tfCountry.text = "Philippines"
            countryCode = Country.PH

        case 1:
            tfCountry.text = "Indonesia"
            countryCode = Country.ID

        default:
            tfCountry.text = "Thailand"
            countryCode = Country.TH
        }

        getEnabledBanks()
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let width = pickerView.bounds.width - 30
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 50 ))
        label.font = UIFont(name: "Ubuntu-Regular", size: 14)

        switch row {
        case 0: label.text = "Philippines"
        case 1: label.text = "Indonesia"
        default: label.text = "Thailand"
        }

        view.addSubview(label)

        return view
    }

}
