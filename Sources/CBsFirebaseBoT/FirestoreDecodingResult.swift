//
//  FirestoreDecodingResult.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

import Foundation


/// A result type intended to eliminate ambiguity in detecting serialization errors and decoding objects retrieved from Firestore. This type is differentiated from `Decoding Result` in that a successful deserialization still returns an Optional of the generic type `T`. Returning Optionals as a result of deserialization is a regrettable side-effect of the `FirebaseFirestoreSwift` library's built-in decoding method.
public enum FirestoreDecodingResult <T: Firestorable> {
    
    case object(T?)
    case codingError(NSError)
}
