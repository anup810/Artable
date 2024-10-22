//
//  StripeCart.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-21.
//

import Foundation

let StripeCart = _StripeCart()
final class _StripeCart{
    var cartItems = [Product]()
    private let stripeCreditCardCut = 0.029
    private let flatFeeCents = 30
    var shippingFee = 0
    
    // variables for subtotal, processing fees , and total
    
    var subtotal: Int{
        var amount = 0
        for item in cartItems{
            let pricePennies = Int(item.price)
            amount += pricePennies
        }
        return amount
    }
    
    var processingFees: Int{
        if subtotal == 0 {
            return 0
        }
        let sub = Double(subtotal)
        let feesAndSub = Int(sub * stripeCreditCardCut) + flatFeeCents
        return feesAndSub
    }
    
    var total : Int{
        return subtotal + processingFees + shippingFee
    }
    
    //menthod to add and remove in shopping cart
    
    func addItemToCart(item: Product){
        cartItems.append(item)
    }
    func removeItemFromCart(item : Product){
        if let index = cartItems.firstIndex(of: item){
            cartItems.remove(at: index)
        }
    }
    
    func clearCart(){
        cartItems.removeAll()
    }
    
}
