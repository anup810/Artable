//
//  ProductDetailsVC.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-25.
//

import UIKit
import Kingfisher

class ProductDetailsVC: UIViewController {
    //outlets
    
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var bgView: UIVisualEffectView!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    
    var product: Product!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productTitle.text = product.name
        productDescription.text = product.productDescription
        if let url = URL(string: product.imageUrl) {
            productImage.kf.setImage(with: url)
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber){
            productPrice.text = price
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissProduct(_:)))
        tap.numberOfTapsRequired = 1
        bgView.addGestureRecognizer(tap)
    }
    
    @objc func dismissProduct(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addToCartButtonClicked(_ sender: Any) {
        //Add product to cart
    }
    
    @IBAction func dismissProductButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
