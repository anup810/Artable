//
//  ViewController.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-16.
//

import UIKit
import Firebase

class HomeVC: UIViewController {
    @IBOutlet weak var loginOutButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If there's no current user, sign in anonymously
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                if let error = error {
                    debugPrint("Error signing in anonymously: \(error.localizedDescription)")
                    self.handleFireAuthError(error: error)
                } else if let user = result?.user {
                    print("Anonymous user signed in: \(user.uid)")
                    self.updateLoginOutButton()
                }
            }
        } else {
            updateLoginOutButton() // Update button if user is already signed in
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLoginOutButton() // Ensure button is up to date when the view appears
    }
    
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: "LoginStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginVC")
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }

    fileprivate func updateLoginOutButton() {
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                loginOutButton.title = "Login"
            } else {
                loginOutButton.title = "Logout"
            }
        }
    }

    @IBAction func loginOutButtonClicked(_ sender: Any) {
        if let user = Auth.auth().currentUser {
            if user.isAnonymous {
                presentLoginController() // Present login if user is anonymous
            } else {
                do {
                    try Auth.auth().signOut() // Sign out if logged in
                    presentLoginController() // Show login after sign out
                } catch {
                    debugPrint("Error signing out: \(error.localizedDescription)")
                    handleFireAuthError(error: error)
                }
            }
        } else {
            presentLoginController() // Present login if no user exists
        }
    }
}
