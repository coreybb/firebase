//
//  Identifiable.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

/// Guarantees that a given object has `id` as a property, and requires the object define a `collection: FirestoreCollection`.
public protocol Identifiable: Firestorable {
    
    var id: String { get set }
}

