//
//  User.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-01.
//

import Foundation

struct User {
    var id: String
    var email:String
    var username:String
    var stripeId: String
    
    init(id: String = "" , email: String = "", username: String = "", stripeId: String = "") {
        self.id = id
        self.email = email
        self.username = username
        self.stripeId = stripeId
    }
    //init for when we get data back from firestore
    
    init(data: [String : Any]) {
        id = data["id"] as? String ?? ""
        email = data["email"] as? String ?? ""
        username = data["username"] as? String ?? ""
        stripeId = data["stripeId"] as? String ?? ""
    }
    static func modalToData(user: User) -> [String: Any]{
        let data : [String:Any] = [
            "id" : user.id,
            "email": user.email,
            "username" : user.username,
            "stripeId" : user.stripeId
            
        ]
        return data
    }
    
}
