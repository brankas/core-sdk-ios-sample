//
//  ViewController.swift
//  TestApp
//
//  Created by Ejay Torres on 11/25/20.
//

import UIKit
import DirectTapFramework
import SDWebImageSVGCoder
import SDWebImage
import RxSwift
import RxCocoa

class ViewController: UIViewController, CheckDelegate {
    typealias T = String
    
    private var destinationBank: DirectBank = .init(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false)
    private var sourceBank: DirectBank = .init(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false)
    private var countryCode: Country = Country.PH

    private var destinationBanks = [
        Country.ID: [
            DirectBank(bankCode: .Dummy_Bank, country: .ID, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .BCA, country: .ID, title: "BCA", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .BNI, country: .ID, title: "BNI", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .BRI, country: .ID, title: "BRI", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .Mandiri, country: .ID, title: "Mandiri", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false)
        ],
        Country.PH: [
            DirectBank(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .BDO, country: .PH, title: "BDO", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .BPI, country: .PH, title: "BPI", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .EAST_WEST, country: .PH, title: "EastWest Bank", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .LAND_BANK, country: .PH, title: "LandBank", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .MB, country: .PH, title: "MetroBank", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .PNB, country: .PH, title: "PNB", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .RCBC, country: .PH, title: "RCBC", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false),
            DirectBank(bankCode: .UB, country: .PH, title: "Union Bank", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false)
        ]
    ]

    private var sourceBanks: [DirectBank] = []
    private var expiryDate = Date()
    private var subscribers: [Disposable] = []


    @IBOutlet weak var swUseRememberMe: UISwitch!
    @IBOutlet weak var swExpiryDate: UISwitch!
    @IBOutlet weak var swLogoURL: UISwitch!
    @IBOutlet weak var swBackButton: UISwitch!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfEmailAddress: UITextField!
    @IBOutlet weak var tfMobileNumber: UITextField!
    @IBOutlet weak var tfCountry: UITextField!
    @IBOutlet weak var tfDestinationBank: UITextField!
    @IBOutlet weak var ivDestinationBank: UIImageView!
    @IBOutlet weak var vSourceBank: UIView!
    @IBOutlet weak var tfSourceBank: UITextField!
    @IBOutlet weak var ivSourceBank: UIImageView!
    @IBOutlet weak var tfDestinationAccountID: UITextField!
    @IBOutlet weak var tfAmount: UITextField!
    @IBOutlet weak var tfMemo: UITextField!
    @IBOutlet weak var tfReferenceID: UITextField!
    @IBOutlet weak var tfOrganizationName: UITextField!
    @IBOutlet weak var tfSuccessURL: UITextField!
    @IBOutlet weak var tfFailURL: UITextField!
    @IBOutlet weak var vLogoURL: UIView!
    @IBOutlet weak var tfLogoURL: UITextField!
    @IBOutlet weak var vExpiryDate: UIView!
    @IBOutlet weak var tfExpiryDate: UITextField!
    @IBOutlet weak var btCheckout: UIButton!
    @IBOutlet weak var vProgressing: UIView!

    @IBAction func onAutoFillDetails(_ sender: Any) {
        tfFirstName.text = "First"
        tfLastName.text = "Last"
        tfEmailAddress.text = "test@example.com"
        tfMobileNumber.text = "09123456789"
        tfAmount.text = "100"
        tfMemo.text = "Sample Bank Transfer"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d yyyy hh:mm:ss"
        tfReferenceID.text = dateFormatter.string(from: Date())

        tfOrganizationName.text = "Sample Org"
        tfSuccessURL.text = "https://google.com"
        tfFailURL.text = "https://hello.com"
        
        tfFirstName.sendActions(for: .editingChanged)
        tfLastName.sendActions(for: .editingChanged)
        tfEmailAddress.sendActions(for: .editingChanged)
        tfMobileNumber.sendActions(for: .editingChanged)
        tfAmount.sendActions(for: .editingChanged)
        tfMemo.sendActions(for: .editingChanged)
        tfReferenceID.sendActions(for: .editingChanged)
        tfOrganizationName.sendActions(for: .editingChanged)
        tfSuccessURL.sendActions(for: .editingChanged)
        tfFailURL.sendActions(for: .editingChanged)
    }

    @IBAction func onEnableExpiryDate(_ sender: Any) {
        vExpiryDate.isHidden = !swExpiryDate.isOn
    }

    @IBAction func onEnableLogoURL(_ sender: Any) {
        vLogoURL.isHidden = !swLogoURL.isOn
    }

    @IBAction func onCheckout(_ sender: Any) {
        if !checkAPIKey() {return}

        vProgressing.isHidden = false
        DirectTapSF.shared.initialize(apiKey: Constants.API_KEY, certPath: nil, isDebug: true)
        
        let account = DirectAccount(country: countryCode, bankCode: sourceBank.bankCode == DirectBankCode.Dummy_Bank ? nil : sourceBank.bankCode)
        let amount = Amount(currency: countryCode == Country.PH ? Currency.php : Currency.idr, numInCents: String(Int64(Float(tfAmount.text ?? "")! * 100)))
        let customer = Customer(firstName: tfFirstName.text ?? "", lastName: tfLastName.text ?? "", email: tfEmailAddress.text ?? "", mobileNumber: tfMobileNumber.text ?? "")
        var client = Client()
        client.displayName = tfOrganizationName.text ?? ""
        client.returnUrl = tfSuccessURL.text ?? ""
        client.failUrl = tfFailURL.text ?? ""
        
        if let logoURL = tfLogoURL.text, !logoURL.isEmpty {
            client.logoUrl = logoURL
        }

        var request = DirectTapRequest(sourceAccount: account, destinationAccountId: tfDestinationAccountID.text ?? "", amount: amount, memo: tfMemo.text ?? "", customer: customer, referenceId: tfReferenceID.text ?? "", client: client, dismissAlert: DismissAlert(message: "Do you want to close the application?", confirmButtonText: "Yes", cancelButtonText: "Cancel"))

        request.browserMode = .WebView
        request.useRememberMe = swUseRememberMe.isOn

        if swExpiryDate.isOn {
            request.expiryDate = expiryDate
        }

        do {
            try DirectTapSF.shared.checkoutWithinSameScreen(tapRequest: request, vc: self, closure: { transaction, err in
                self.onResult(data: transaction, error: err)
            }, showWithinSameScreen: true, showBackButton: swBackButton.isOn)
        } catch {
            vProgressing.isHidden = true
            print("Error: \(error)")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)

        vSourceBank.isHidden = true
        vLogoURL.isHidden = true
        vExpiryDate.isHidden = true

        let countryPicker = UIPickerView()
        countryPicker.delegate = self
        countryPicker.tag = 1
        tfCountry.inputView = countryPicker

        let destBankPicker = UIPickerView()
        destBankPicker.delegate = self
        destBankPicker.tag = 2
        tfDestinationBank.inputView = destBankPicker

        let sourceBankPicker = UIPickerView()
        sourceBankPicker.delegate = self
        sourceBankPicker.tag = 3
        tfSourceBank.inputView = sourceBankPicker

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(expiryDateChanged), for: .valueChanged)
        tfExpiryDate.inputView = datePicker
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscribers.append(Observable.combineLatest(
            Observable.combineLatest(
                tfFirstName.rx.controlEvent(.editingChanged),
                tfLastName.rx.controlEvent(.editingChanged),
                tfEmailAddress.rx.controlEvent(.editingChanged),
                tfMobileNumber.rx.controlEvent(.editingChanged),
                tfDestinationAccountID.rx.controlEvent(.editingChanged),
                tfAmount.rx.controlEvent(.editingChanged)
            ),
            Observable.combineLatest(
                tfMemo.rx.controlEvent(.editingChanged),
                tfReferenceID.rx.controlEvent(.editingChanged),
                tfOrganizationName.rx.controlEvent(.editingChanged),
                tfSuccessURL.rx.controlEvent(.editingChanged),
                tfFailURL.rx.controlEvent(.editingChanged)
            )
        ).subscribe(onNext: { _ in
            self.formValidation()
        }))

        tfDestinationAccountID.text = Constants.DESTINATION_ACCOUNT_ID
        tfDestinationAccountID.sendActions(for: .editingChanged)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        subscribers.forEach { $0.dispose() }
        subscribers.removeAll()
    }

    @objc func expiryDateChanged(datePicker: UIDatePicker) {
        let date = datePicker.date
        expiryDate = date

        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        tfExpiryDate.text = df.string(from: date)
    }

    private func onResult(data: Transaction?, error: String?) {
        if let transaction = data {
            let date = DateFormatter()
            date.dateFormat = "MMMM dd YYYY"

            let bankFee = Float(transaction.bankFee.numInCents) ?? 0 / 100
            let amount = Float(transaction.amount.numInCents) ?? 0 / 100
            let finishedDate = date.string(from: transaction.finishedDate)

            let fee = "\(transaction.bankFee.currency) \(bankFee)"
            let payment = "\(transaction.amount.currency) \(amount)"

            showAlert(message: "TRANSACTION (\(transaction.id))\nReference ID: \(transaction.referenceId)\nStatus: \(transaction.status)\nStatus Code: \(transaction.statusMessage ?? "") (\(transaction.statusCode))\nBank: \(transaction.bankCode) (\(transaction.country))\nAmount: \(payment)\nBank Fee:\(fee)\nDate: \(finishedDate)")
        }
        
        if let message = error {
            showAlert(message: "Error: \(message)")
        }
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

    func getSourceBanks() {
        if "None" == destinationBank.title {return}

        vProgressing.isHidden = false
        DirectTapSF.shared.initialize(apiKey: Constants.API_KEY, certPath: nil, isDebug: false)
        DirectTapSF.shared.getSourceBanks(country: countryCode, destinationBank: destinationBank.bankCode) { banks, error in
            if let error = error {
                self.showAlert(message: error)
                return
            }

            self.vProgressing.isHidden = true
            self.sourceBanks.append(contentsOf: banks)

            banks.forEach { bank in
                self.destinationBanks[Country.ID]?.enumerated().forEach { index, item in
                    if item.bankCode == bank.bankCode {
                        self.destinationBanks[Country.ID]![index].logoUrl = bank.logoUrl
                    }
                }
                self.destinationBanks[Country.PH]?.enumerated().forEach { index, item in
                    if item.bankCode == bank.bankCode {
                        self.destinationBanks[Country.PH]![index].logoUrl = bank.logoUrl
                    }
                }

                if self.destinationBank.bankCode == bank.bankCode {
                    self.destinationBank.logoUrl = bank.logoUrl
                    self.ivDestinationBank.sd_setImage(with: URL(string: bank.logoUrl), placeholderImage: UIImage(named: "ic_banking"))
                }
            }

        }
    }

    private func formValidation() {
        guard let firstName = self.tfFirstName.text, !firstName.isEmpty,
              let lastName = self.tfLastName.text, !lastName.isEmpty,
              let email = self.tfEmailAddress.text, !email.isEmpty,
              let mobile = self.tfMobileNumber.text, !mobile.isEmpty,
              let destAccountID = self.tfDestinationAccountID.text, !destAccountID.isEmpty,
              let amountStr = self.tfAmount.text, !amountStr.isEmpty,
              let memo = self.tfMemo.text, !memo.isEmpty,
              let referenceID = self.tfReferenceID.text, !referenceID.isEmpty,
              let orgName = self.tfOrganizationName.text, !orgName.isEmpty,
              let successURL = self.tfSuccessURL.text, !successURL.isEmpty,
              let failURL = self.tfFailURL.text, !failURL.isEmpty
        else {
            self.btCheckout.isEnabled = false
            self.btCheckout.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
            return
        }

        var amount = Double(tfAmount.text ?? "") ?? 0.0
        amount *= 100.0

        if !isValidEmail()
            || (!mobile.hasPrefix("09") || 11 != mobile.count)
            || (!successURL.hasPrefix("http://") && !successURL.hasPrefix("https://") && !successURL.hasPrefix("www."))
            || (!failURL.hasPrefix("http://") && !failURL.hasPrefix("https://") && !failURL.hasPrefix("www."))
            || (0.0 >= amount)
        {
            self.btCheckout.isEnabled = false
            self.btCheckout.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
            return
        }


        if "None" == destinationBank.title && "None" == sourceBank.title {
            self.btCheckout.isEnabled = true
            self.btCheckout.backgroundColor = UIColor(red: 57/255, green: 128/255, blue: 196/255, alpha: 1)
            return
        } else if "None" != sourceBank.title {
            let min = destinationBank.bankCode == sourceBank.bankCode
            ? Double(sourceBank.fundTransferLimit?.intrabankMinLimit.numInCents ?? "0.0") ?? 0.0
            : Double(sourceBank.fundTransferLimit?.interbankMinLimit.numInCents ?? "0.0") ?? 0.0

            let max = destinationBank.bankCode == sourceBank.bankCode
            ? Double(sourceBank.fundTransferLimit?.intrabankMaxLimit.numInCents ?? "0.0") ?? 0.0
            : Double(sourceBank.fundTransferLimit?.interbankMaxLimit.numInCents ?? "0.0") ?? 0.0

            if 0.0 == amount || amount < min || amount > max {
                self.btCheckout.isEnabled = false
                self.btCheckout.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
                return
            }
        }

        self.btCheckout.isEnabled = true
        self.btCheckout.backgroundColor = UIColor(red: 57/255, green: 128/255, blue: 196/255, alpha: 1)
    }

    private func isValidEmail() -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&???*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&???*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: tfEmailAddress.text ?? "")
        return result
    }

}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1: return 2    // country selection
        case 2: return destinationBanks[countryCode]?.count ?? 0 // destination bank
        case 3: return sourceBanks.count // source bank
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: // country selection
            if 0 == row {
                tfCountry.text = "Philippines"
                countryCode = Country.PH
            } else {
                tfCountry.text = "Indonesia"
                countryCode = Country.ID
            }
            destinationBank = .init(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false)
            tfDestinationBank.text = "None"
            ivDestinationBank.image = UIImage(named: "ic_banking")
            vSourceBank.isHidden = true
            sourceBank = .init(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false)
            tfSourceBank.text = "None"
            ivSourceBank.image = UIImage(named: "ic_banking")
            sourceBanks = []
            sourceBanks.append(.init(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false))

        case 2: // destination bank
            guard let bank = destinationBanks[countryCode]?[row] else {return}
            destinationBank = bank
            tfDestinationBank.text = bank.title
            ivDestinationBank.sd_setImage(with: URL(string: bank.logoUrl), placeholderImage: UIImage(named: "ic_banking"))
            sourceBank = .init(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false)
            tfSourceBank.text = "None"
            ivSourceBank.image = UIImage(named: "ic_banking")
            sourceBanks = []
            sourceBanks.append(.init(bankCode: .Dummy_Bank, country: .PH, title: "None", logoUrl: "", fundTransferLimit: .init(), fundTransferFee: .init(), isCorporate: false))

            if "None" == destinationBank.title {
                vSourceBank.isHidden = true
            } else {
                vSourceBank.isHidden = false
                getSourceBanks()
            }

        case 3: // source bank
            sourceBank = sourceBanks[row]
            tfSourceBank.text = sourceBank.title
            ivSourceBank.sd_setImage(with: URL(string: sourceBank.logoUrl), placeholderImage: UIImage(named: "ic_banking"))

        default: return
        }

        formValidation()
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let width = pickerView.bounds.width - 30
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 50))

        switch pickerView.tag {
        case 1: // country selection
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 50 ))
            label.font = UIFont(name: "Ubuntu-Regular", size: 14)
            label.text = 0 == row ? "Philippines" : "Indonesia"
            view.addSubview(label)

        case 2: // destination bank
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width - 40, height: 50 ))
            label.font = UIFont(name: "Ubuntu-Regular", size: 14)
            label.text = destinationBanks[countryCode]?[row].title
            view.addSubview(label)

            let imageView = UIImageView(frame: CGRect(x: width - 40, y: 10, width: 30, height: 30))
            imageView.contentMode = .scaleAspectFit
            imageView.sd_setImage(with: URL(string: destinationBanks[countryCode]?[row].logoUrl ?? ""), placeholderImage: UIImage(named: "ic_banking"))
            view.addSubview(imageView)

        case 3: // destination bank
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: width - 40, height: 50 ))
            label.font = UIFont(name: "Ubuntu-Regular", size: 14)
            label.text = sourceBanks[row].title
            view.addSubview(label)

            let imageView = UIImageView(frame: CGRect(x: width - 40, y: 10, width: 30, height: 30))
            imageView.contentMode = .scaleAspectFit
            imageView.sd_setImage(with: URL(string: sourceBanks[row].logoUrl), placeholderImage: UIImage(named: "ic_banking"))
            view.addSubview(imageView)

        default:
            return view
        }

        return view
    }

}
