//
//  ForgotPasswordVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-21.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonClicked(_ sender: Any) {
        guard let email = emailText.text, email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Please enter email.")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email){error in
            if let error = error {
                debugPrint(error.localizedDescription)
                self.handleFireAuthError(error: error)
                return
            }
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
}
