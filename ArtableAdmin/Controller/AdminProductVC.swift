//
//  AdminProductVC.swift
//  ArtableAdmin
//
//  Created by Anup Saud on 2024-09-28.
//

import UIKit

class AdminProductVC: ProductVC {
    var selectedProduct : Product?

    override func viewDidLoad() {
        super.viewDidLoad()
        let editCategory = UIBarButtonItem(title: "Edit Category", style: .plain, target: self, action: #selector(editCategory))
        let newProductButton = UIBarButtonItem(title: "Add Product", style: .plain, target: self, action: #selector(newProduct))
        navigationItem.setRightBarButtonItems([editCategory, newProductButton], animated: false)


    }
    
    @objc func editCategory(){
        performSegue(withIdentifier: Segus.ToEditCategory, sender: self)
        
    }
    @objc func newProduct(){
        performSegue(withIdentifier: Segus.ToAddEditProduct, sender: self)
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //editing product
        selectedProduct = products[indexPath.row]
        performSegue(withIdentifier: Segus.ToAddEditProduct, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segus.ToAddEditProduct {
            if let destination = segue.destination as? AddEditProductVC{
                destination.selectedCategory = category
                destination.productToEdit = selectedProduct
            }
        }else if segue.identifier == Segus.ToEditCategory{
            if let destination = segue.destination as? AddEditCategoryVC{
                destination.categoryToEdit = category
            }
            
        }
    }
 

}
