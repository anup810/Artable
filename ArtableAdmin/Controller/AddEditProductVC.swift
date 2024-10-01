//
//  AddEditProductVC.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-09-28.
//

import UIKit

class AddEditProductVC: UIViewController {
    var productToEdit: Product?
    var selectedCategory: Category!
    
    //outlets
    
    @IBOutlet weak var productNameText: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    
    @IBOutlet weak var addProductButton: RoundedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var productDescText: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func addEditProductButtonClicked(_ sender: Any) {
    }
    

}
