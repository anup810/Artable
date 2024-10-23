//
//  LoginVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-17.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func forgotPassButtonClicked(_ sender: Any) {
        let vc = ForgotPasswordVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        guard let email = emailText.text, email.isNotEmpty, let password = passwordText.text, password.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please fill out all fields.")
            return
        }
        activityIndicator.startAnimating()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error{
                debugPrint(error.localizedDescription)
                Auth.auth().handleFireAuthError(error: error,vc: self!)
               // Auth.auth().handleFireAuthError(error: error,vc: self)
                self?.activityIndicator.stopAnimating()
                return

            }
            self?.activityIndicator.stopAnimating()
            self?.dismiss(animated: true, completion: nil)
          
        }
    }
    
    @IBAction func guestButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
