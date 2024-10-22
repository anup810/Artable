//
//  StripeApi.swift
//  Artable
//
//  Created by Anup Saud on 2024-10-22.
//

import Foundation
import Stripe
import FirebaseFunctions

let StripeApi = _StripeApi()

class _StripeApi: NSObject, STPCustomerEphemeralKeyProvider {
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        guard !userService.user.striprId.isEmpty else {
            let error = NSError(domain: "StripeAPI",
                              code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Customer ID not found"])
            completion(nil, error)
            return
        }
        
        let data = [
            "stripe_version": apiVersion,
            "customer_id": userService.user.striprId
        ]
        
        print("Creating ephemeral key for customer: \(userService.user.striprId)")
        
        Functions.functions().httpsCallable("createEphemeralKey").call(data) { (result, error) in
            if let error = error {
                print("Ephemeral Key Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let key = result?.data as? [String: Any] else {
                let error = NSError(domain: "StripeAPI",
                                  code: -2,
                                  userInfo: [NSLocalizedDescriptionKey: "Invalid key format received"])
                completion(nil, error)
                return
            }
            
            print("Successfully created ephemeral key")
            completion(key, nil)
        }
    }
}
