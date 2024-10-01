//
//  AdminHomeVC.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-10-01.
//

import UIKit

class AdminHomeVC: HomeVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        let addCategoryBtn = UIBarButtonItem(title: "Add Category", style: .plain, target: self, action: #selector(addCategory))
        navigationItem.rightBarButtonItem = addCategoryBtn
    }
    
    @objc func addCategory() {
        performSegue(withIdentifier: Segus.ToAddEditCategory, sender: self)
    }
}

