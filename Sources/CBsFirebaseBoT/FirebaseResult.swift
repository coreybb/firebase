//
//  FirebaseResult.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

public enum FirebaseResult <T: Codable> {
    
    case object(T)
    case error(FirebaseError)
}
