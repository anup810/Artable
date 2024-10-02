//
//  UserService.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-01.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

let userService = _UserService()
final class _UserService{
    
    //Variables
    var user = User()
    var favorites = [Product]()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener : ListenerRegistration? = nil
    var favListener : ListenerRegistration? = nil
    
    // to find out if the user is guest or not
    
    var isGuest : Bool{
        guard let authUser = auth.currentUser else {
            return true
        }
        if authUser.isAnonymous {
            return true
        }else {
            return false
        }
    }
    
    //get the current user information and favorite
    
    func getCurrentUser(){
        guard let authUser = auth.currentUser else {return}
        let userRef = db.collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener { snap, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            guard let data = snap?.data() else {return}
            self.user =  User.init(data: data)
            print(self.user)
        }
        let favRef = userRef.collection("favorites")
        favListener = favRef.addSnapshotListener({ snap, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documents.forEach({ document in
                let favorite = Product.init(data: document.data())
                self.favorites.append(favorite)
            })
        })
        
    }
    func favoriteSelected(product: Product){
        let favsRef = db.collection("users").document(user.id).collection("favorites")
        if favorites.contains(product){
            //remove it as favorites
            favorites.removeAll{$0 == product}
            favsRef.document(product.id).delete()
            
        }else{
            //add as a favorites
            favorites.append(product)
            let data = Product.modelToData(product: product)
            favsRef.document(product.id).setData(data)
            
        }
        
    }
    func logoutUser(){
        userListener?.remove()
        userListener = nil
        favListener?.remove()
        favListener = nil
        user = User()
        favorites.removeAll()
    }
    
}
