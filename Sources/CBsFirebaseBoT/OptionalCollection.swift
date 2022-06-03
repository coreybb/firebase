//
//  OptionalCollection.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

extension Optional where Wrapped: Collection {
    
    func isNilOrEmpty() -> Bool {
        self?.isEmpty ?? true
    }
}
