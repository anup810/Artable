//
//  Product.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-22.
//

import Foundation
import FirebaseFirestore

struct Product{
    var name:String
    var id:String
    var category:String
    var price: Double
    var productDescription: String
    var imageURL: String
    var timeStamp: Timestamp
    var stock: Int
    var favorite: Bool
}
