//
//  CategoryCell.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-22.
//

// CategoryCell.swift
import UIKit
import Kingfisher

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImage.layer.cornerRadius = 5
        categoryImage.clipsToBounds = true
    }
    
    func configureCell(category: Category) {
        categoryName.text = category.name
        if let url = URL(string: category.imageUrl) {
            let placeholder = UIImage(named: "placeholder")
            categoryImage.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.2))])
        }
    }
}
