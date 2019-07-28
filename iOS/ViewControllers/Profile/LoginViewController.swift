//
//  LoginViewController.swift
//  GitHub iOS
//
//  Created by Eduardo Irias on 10/31/17.
//  Copyright © 2017 Estamp. All rights reserved.
//

import UIKit
import SafariServices

protocol LoginViewControllerDelegate: AnyObject {
    func loginViewController(_ loginViewController: LoginViewController, didLoginWith user: User)
    func didCancel(_ loginViewController: LoginViewController)
}

class LoginViewController: UIViewController {

    weak var delegate: LoginViewControllerDelegate?
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions

    @IBAction func setUsernameTextFieldResponderAction(_ sender: Any) {
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func setPasswordTextFieldResponderAction(_ sender: Any) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }
        
        if username == "" || password == "" {
            return
        }
        
        DataManager.shared.postLogin(username: username, password: password) { (user, error) in
            if let error = error  {
                if error == .otpRequired {
                    let alert = UIAlertController(title: "Authentication code", message: "Two-factor authentication is enabled for this account", preferredStyle: .alert)
                    
                    alert.addTextField { (textField) in
                        textField.placeholder = "000000"
                        textField.text = ""
                    }
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        guard let textField = alert?.textFields?.first else {
                            return
                        }
                        DataManager.shared.postLogin(username: username, password: password, otp: textField.text) { (user, error) in
                            if let user = user {
                                self.delegate?.loginViewController(self, didLoginWith: user)
                            }
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            if let user = user {
                self.delegate?.loginViewController(self, didLoginWith: user)
            }
        }
    }

    @IBAction func forgotPasswordAction(_ sender: Any) {
        guard let url = URL(string: "https://github.com/password_reset") else {
            return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        delegate?.didCancel(self)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if usernameTextField == textField {
            passwordTextField.becomeFirstResponder()
        } else {
            loginAction(textField)
        }
        return true
    }
        
}
