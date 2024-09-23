//
//  File.swift
//  Artable
//
//  Created by Anup Saud on 2024-09-22.
//
import FirebaseFirestore
import Foundation

struct Category {
    var name: String
    var id: String
    var imageUrl: String
    var isActive: Bool = true
    var timeStamp: Timestamp
}
