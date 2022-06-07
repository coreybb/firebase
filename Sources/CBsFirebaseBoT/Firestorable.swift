//
//  Firestorable.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

public protocol Firestorable: Codable, AnyObject {
    
    static var collection: FirestoreCollection { get }
}
