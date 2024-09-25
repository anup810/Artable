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
    
    init(data:[String : Any]){
        self.name = data["name"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.category = data["category"] as? String ?? ""
        self.price  = data["price"] as? Double ?? 0.0
        self.productDescription = data["productDescription"] as? String ?? ""
        self.imageURL = data["imageUrl"] as? String ?? ""
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()
        self.stock = data["stock"] as? Int ?? 0
        self.favorite = data["favorite"] as? Bool ?? true
    }
}
