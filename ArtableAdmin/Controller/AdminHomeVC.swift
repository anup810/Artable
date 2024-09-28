//
//  ViewController.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-09-16.
//

import UIKit

class AdminHomeVC: HomeVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Admin"
        // Call your custom setup for the admin home
        setupAdminUI()
    }

    func setupAdminUI() {
        navigationItem.leftBarButtonItem?.isEnabled = false
        let addCategoryButton = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryButton
    }
    
    @objc func addCategory() {
        // Transition to AddCategoryVC
        performSegue(withIdentifier: Segus.ToAddEditCategory, sender: self)

    }
}
