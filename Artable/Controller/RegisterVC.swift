//
//  RegisterVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-17.
//

import UIKit
import Firebase
import FirebaseFirestore

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
        print("Register button pressed") // Ensure the action is linked properly.
        
        guard let email = emailText.text, email.isNotEmpty,
              let userName = usernameText.text, userName.isNotEmpty,
              let password = passwordText.text, password.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please fill out all fields")
            activityIndicator.stopAnimating() // Stop spinner
            return
        }

        guard let confrimPassword = confrimPasswordText.text, confrimPassword == password else {
            simpleAlert(title: "Error", msg: "Passwords do not match.")
            activityIndicator.stopAnimating() // Stop spinner
            return
        }
        
        activityIndicator.startAnimating()

        // Check if there is an authenticated user
        if let authUser = Auth.auth().currentUser {
            // If the user is anonymous, link with email/password
            linkAnonymousUserWithEmailPassword(email: email, password: password, userName: userName, authUser: authUser)
        } else {
            // No authenticated user found, sign in anonymously first
            Auth.auth().signInAnonymously { (authResult, error) in
                if let error = error {
                    print("Error signing in anonymously: \(error.localizedDescription)")
                    self.activityIndicator.stopAnimating() // Stop spinner
                    return
                }
                
                guard let authUser = authResult?.user else {
                    print("Anonymous sign-in failed")
                    self.activityIndicator.stopAnimating() // Stop spinner
                    return
                }

                // Now link the anonymous user with email/password
                self.linkAnonymousUserWithEmailPassword(email: email, password: password, userName: userName, authUser: authUser)
            }
        }
    }

    func linkAnonymousUserWithEmailPassword(email: String, password: String, userName: String, authUser: FirebaseAuth.User) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        authUser.link(with: credential) { (result, error) in
            if let error = error {
                debugPrint("Error linking account: \(error.localizedDescription)")
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityIndicator.stopAnimating() // Stop spinner
                return
            }

            guard let fireUser = result?.user else {
                print("User linking succeeded but no user object returned")
                self.activityIndicator.stopAnimating() // Stop spinner
                return
            }
            
            // Create your custom Artable.User using properties from FirebaseAuth.User
            let artUser = User(id: fireUser.uid, email: fireUser.email ?? "", username: userName, stripeId: "")
            // Upload to Firestore
            self.createFireStoreUser(user: artUser)
        }
    }



        
//        if let authUser = Auth.auth().currentUser {
//            if authUser.isAnonymous {
//                // Link the anonymous account with the new email/password account
//                linkAccountWithEmailPassword(email: email, password: password, userName: userName)
//            } else {
//                // If the current user is not anonymous
//                simpleAlert(title: "Error", msg: "Current user is already registered.")
//                activityIndicator.stopAnimating()
//            }
//        } else {
//            // If no user is signed in, register a new user
//            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
//                if let error = error {
//                    self.simpleAlert(title: "Error", msg: error.localizedDescription)
//                    self.activityIndicator.stopAnimating()
//                    return
//                }
//                guard let fireUser = authResult?.user else { return }
//                let artUser = User(id: fireUser.uid, email: email, username: userName, striprId: "")
//                self.createFireStoreUser(user: artUser)
//            }
//        }
//    }
//    
//    func linkAccountWithEmailPassword(email: String, password: String, userName: String) {
//        guard let authUser = Auth.auth().currentUser else { return }
//        
//        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
//        
//        authUser.link(with: credential) { (result, error) in
//            if let error = error {
//                debugPrint("Failed to link account: \(error.localizedDescription)")
//                Auth.auth().handleFireAuthError(error: error, vc: self)
//                self.activityIndicator.stopAnimating()
//                return
//            }
//            guard let fireUser = result?.user else { return }
//            let artUser = User(id: fireUser.uid, email: email, username: userName, striprId: "")
//            self.createFireStoreUser(user: artUser)
//        }
//    }
    
    func createFireStoreUser(user: User) {
        // Create document reference
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        
        // Create model data
        let data = User.modalToData(user: user)
        
        // Upload to Firestore
        newUserRef.setData(data) { error in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint("Unable to upload new user Document: \(error.localizedDescription)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
        }
    }
}
