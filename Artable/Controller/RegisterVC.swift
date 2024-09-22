//
//  RegisterVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-17.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var confrimPassCheckImg: UIImageView!
    @IBOutlet weak var passCheckImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var confrimPasswordText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        confrimPasswordText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let passText = passwordText.text else { return }
        
        if textField == confrimPasswordText {
            passCheckImg.isHidden = false
            confrimPassCheckImg.isHidden = false
        } else {
            if passText.isEmpty {
                passCheckImg.isHidden = true
                confrimPassCheckImg.isHidden = true
                confrimPasswordText.text = ""
            }
        }
        
        if passwordText.text == confrimPasswordText.text {
            passCheckImg.image = UIImage(named: AppImages.GreenCheck)
            confrimPassCheckImg.image = UIImage(named: AppImages.GreenCheck)
        } else {
            passCheckImg.image = UIImage(named: AppImages.RedCheck)
            confrimPassCheckImg.image = UIImage(named: AppImages.RedCheck)
        }
    }
    
    // Register button action
    @IBAction func Register(_ sender: Any) {
        guard let email = emailText.text, email.isNotEmpty,
              let userName = usernameText.text, userName.isNotEmpty,
              let password = passwordText.text, password.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please fill out all fields")
            return
        }
        guard let confrimPassword = confrimPasswordText.text , confrimPassword == password else {
            simpleAlert(title: "Error", msg: "Passwords do not match.")
            return
        }
        
        activityIndicator.startAnimating()
        
        // Ensure the current user is authenticated anonymously
        guard let authUser = Auth.auth().currentUser else {
            print("No anonymous user found")
            activityIndicator.stopAnimating()
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        // Link anonymous user with email/password credential
        authUser.link(with: credential) { (result, error) in
            
            if let error = error {
                debugPrint("Failed to link account: \(error.localizedDescription)")
                self.handleFireAuthError(error: error)
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
            
        }
       
    }
}
