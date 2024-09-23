//
//  CategoryCell.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-22.
//

import UIKit
import Kingfisher
class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        categoryImage.layer.cornerRadius = 5
    }
    func configureCell(category: Category){
        categoryName.text = category.name
        if let url = URL(string: category.imageUrl){
            categoryImage.kf.setImage(with: url)
        }
    }

}
