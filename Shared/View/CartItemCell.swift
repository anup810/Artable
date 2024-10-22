//
//  CartItemCell.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-21.
//

import UIKit

class CartItemCell: UITableViewCell {
    @IBOutlet weak var productImage: RoundedImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var removeButtonLabel: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeButtonClicked(_ sender: Any) {
    }
}
