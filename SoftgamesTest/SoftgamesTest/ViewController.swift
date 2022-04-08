//
//  ViewController.swift
//  SoftgamesTest
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextfield: UITextField!
    @IBOutlet var nameSubmitButton: UIButton!
    @IBOutlet var dateOfBirthTextField: UITextField!
    @IBOutlet var dobSubmitButton: UIButton!
    
    var datePickerView: UIDatePicker!
    
    var webView = WKWebView()
    let config = WKWebViewConfiguration()
    
    let sendNotification = "sendNotification"
    let goBack = "goBack"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config.userContentController = WKUserContentController()
        config.userContentController.add(self, name: sendNotification)
        config.userContentController.add(self, name: goBack)
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        showDatePicker()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if firstNameTextField.isFirstResponder {
            firstNameTextField.resignFirstResponder()
        } else if lastNameTextfield.isFirstResponder {
            lastNameTextfield.resignFirstResponder()
        } else if dateOfBirthTextField.isFirstResponder {
            dateOfBirthTextField.resignFirstResponder()
        }
    }
    
    func showDatePicker() {
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.locale = .current
        datePickerView.maximumDate = Date()
        if #available(iOS 14, *) {
            datePickerView.preferredDatePickerStyle = .wheels
            datePickerView.sizeToFit()
        }
        datePickerView.addTarget(self, action: #selector(self.pickValue(_:)), for: .valueChanged)
        self.setUpDatePicker()
    }
    
    func setUpDatePicker() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
        let doneBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneBtnTapped))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([space, doneBtn], animated: false)
        dateOfBirthTextField.inputView = datePickerView
        self.dateOfBirthTextField.inputAccessoryView = toolBar
    }
    
    @objc func pickValue(_ textField: UITextField) {
        dateOfBirthTextField.text = self.datePickerView.date.toString()
    }
    
    @objc func doneBtnTapped() {
        dateOfBirthTextField.text = self.datePickerView.date.toString()
        dateOfBirthTextField.resignFirstResponder()
    }
    
    func passValueToURLWithParameters(Key: String, Value: String) {
        if let url = Bundle.main.url(forResource: "task", withExtension: "html") {
            let stringURL = "\(url)?\(Key)=\(Value)"
            if let newURL = URL(string: stringURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                let request = URLRequest(url: newURL)
                webView.load(request)
            }
        }
        if webView.isHidden {
            webView.isHidden = false
        } else {
            self.view.addSubview(webView)
        }
    }
    
    @IBAction func nameSubmitButtonTapped(_ sender: UIButton) {
        var name = ""
        if let firstName = firstNameTextField.text, !firstName.isEmpty,
           let lastName = lastNameTextfield.text, !lastName.isEmpty {
            name = "\(firstName) \(lastName)"
            passValueToURLWithParameters(Key: "name", Value: name)
        } else {
            showAlertView(withMessage: "Please enter full name.")
        }
        if firstNameTextField.isFirstResponder {
            firstNameTextField.resignFirstResponder()
        } else if lastNameTextfield.isFirstResponder {
            lastNameTextfield.resignFirstResponder()
        }
    }
    
    @IBAction func dobSubmitButtonTapped(_ sender: UIButton) {
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        var dob = ""
        if let dobText = dateOfBirthTextField.text, !dobText.isEmpty{
            dob = "\(dobText)"
            passValueToURLWithParameters(Key: "Age", Value: dob)
        } else {
            showAlertView(withMessage: "Please select date of birth.")
        }
    }
    
    func showAlertView(withMessage message: String) {
        let alertView = UIAlertController(title: "Solitaire smash", message: message, preferredStyle: .alert)
        let alertOKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(alertOKAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func closeApplication() {
        UIScreen.main.wantsSoftwareDimming = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                exit(0)
            }
        }
    }
}

extension ViewController: WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint(message.name)
        debugPrint(message.body)
        if message.name == sendNotification {
            //Send Notification
            guard let body = message.body as? [String:AnyObject],
                  let isNotification = body["isNotif"] as? Bool else { return }
            debugPrint("\n------Notification------\n", isNotification)
            if isNotification {
                //Create local notification
                createNotification()
                closeApplication()
            } else {
                removeLocalNotification()
            }
        } else if message.name == goBack {
            removeLocalNotification()
        }
        datePickerView.isHidden = true
        webView.isHidden = true
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dateOfBirthTextField {
            showDatePicker()
        } else {
            datePickerView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}
