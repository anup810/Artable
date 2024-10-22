//
//  CartItemCell.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-21.
//

import UIKit

protocol CartItemDelegate: AnyObject {
    func removeItem(product: Product)
}

class CartItemCell: UITableViewCell {
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var removeButtonLabel: UIButton!
    
    private var item: Product!
    weak var delegate : CartItemDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(product: Product, delegate: CartItemDelegate){
        self.delegate = delegate
        self.item = product
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if let price = formatter.string(from: product.price as NSNumber){
            titleLabel.text = "\(product.name) \(price)"
        }
        if let url = URL(string: product.imageUrl){
            productImage.kf.setImage(with: url)
        }
    }


    @IBAction func removeButtonClicked(_ sender: Any) {
        delegate?.removeItem(product: item)
    }
}
