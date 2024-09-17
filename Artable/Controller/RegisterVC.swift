//
//  RegisterVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-17.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {
    //outlets
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
    @objc func textFieldDidChange(_ textField: UITextField){
        guard let passText = passwordText.text else {return}
        // show passcheckimage when we start typing confrim password text
        if textField == confrimPasswordText{
            passCheckImg.isHidden = false
            confrimPassCheckImg.isHidden = false
        }else{
            if passText.isEmpty{
                passCheckImg.isHidden = true
                confrimPassCheckImg.isHidden = true
                confrimPasswordText.text = ""
            }
        }
        //check for password and confrim password , if they match change img to green otherwise red
        if passwordText.text == confrimPasswordText.text {
            passCheckImg.image = UIImage(named: AppImages.GreenCheck)
            confrimPassCheckImg.image = UIImage(named: AppImages.GreenCheck)
        }else {
            passCheckImg.image = UIImage(named: AppImages.RedCheck)
            confrimPassCheckImg.image = UIImage(named:  AppImages.RedCheck)
        }
    }
    //register button
    @IBAction func Register(_ sender: Any) {
        guard let email = emailText.text, email.isNotEmpty,
              let userName = usernameText.text, userName.isNotEmpty,
              let password = passwordText.text, password.isNotEmpty
        else {return}
        
        activityIndicator.startAnimating()
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error{
                debugPrint(error)
                return
            }
            self.activityIndicator.stopAnimating()
            print("Register")
            
        }
    }
    
    
}
