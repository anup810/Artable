//  File.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-22.
//

import FirebaseFirestore
import Foundation

// The Category struct is a model that represents a category in the Firestore database.
struct Category {

    // Properties of the Category struct
    var name: String        // Name of the category
    var id: String          // Unique identifier for the category document in Firestore
    var imageUrl: String    // URL string pointing to the category image stored in Firebase Storage
    var isActive: Bool = true   // Boolean indicating whether the category is active or not
    var timeStamp: Timestamp    // Timestamp of when the category was created or last updated

    // Initializer for creating a Category instance from individual property values
    init(name: String, id: String, imageUrl: String, isActive: Bool = true, timeStamp: Timestamp) {
        self.name = name
        self.id = id
        self.imageUrl = imageUrl
        self.isActive = isActive
        self.timeStamp = timeStamp
    }

    // Initializer for creating a Category instance from a dictionary (used when retrieving data from Firestore)
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""   // Safely unwrap the name from the dictionary
        self.id = data["id"] as? String ?? ""       // Safely unwrap the id from the dictionary
        self.imageUrl = data["imageUrl"] as? String ?? ""  // Safely unwrap the imageUrl from the dictionary
        self.isActive = data["isActive"] as? Bool ?? true  // Safely unwrap the isActive status
        self.timeStamp = data["timeStamp"] as? Timestamp ?? Timestamp()  // Safely unwrap the timestamp
    }

    // Static function that converts a Category object into a dictionary for uploading to Firestore
    static func modelToData(category: Category) -> [String: Any] {
        // Create a dictionary where the keys match the Firestore field names and the values come from the Category properties
        let data: [String: Any] = [
            "name": category.name,
            "id": category.id,
            "imageUrl": category.imageUrl,
            "isActive": category.isActive,
            "timeStamp": category.timeStamp
        ]
        return data  // Return the dictionary so it can be used to set data in Firestore
    }
}
