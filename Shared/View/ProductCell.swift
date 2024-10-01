//
//  ProductCell.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-22.
//

import UIKit
import Kingfisher

class ProductCell: UITableViewCell {
    @IBOutlet weak var productImage: RoundedImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var prodcutPrice: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    func configureCell(product: Product){
        productTitle.text = product.name
        prodcutPrice.text = String(product.price)
        if let url = URL(string: product.imageUrl){
//            productImage.kf.setImage(with: url)
            let placeholderImage = UIImage(named: "placeholder")
            productImage.kf.indicatorType = .activity
            let options: KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            productImage.kf.setImage(with: url,placeholder: placeholderImage,options: options)
            
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if let price = formatter.string(from: product.price as NSNumber){
            prodcutPrice.text = price
        }
    
    }
    
    @IBAction func addToCardButtonClicked(_ sender: Any) {
    }
    @IBAction func favoriteButtonClicked(_ sender: Any) {
    }
}
