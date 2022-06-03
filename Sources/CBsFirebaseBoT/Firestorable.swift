//
//  Firestorable.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

protocol Firestorable: Codable {
    
    var collection: FirestoreCollection { get }
}
