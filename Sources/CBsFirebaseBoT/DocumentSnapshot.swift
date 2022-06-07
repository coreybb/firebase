//
//  DocumentSnapshot.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift


extension DocumentSnapshot {
    
    
    typealias DecodedObject <T: Firestorable> = (_ result: FirestoreDecodingResult<T>) -> ()
    
    
    //---------------------
    //  MARK: - Public API
    //---------------------
    func decoded <T: Firestorable>(type: T.Type) -> FirestoreDecodingResult<T> {
        
        do {
            return .object(try self.data(as: T.self))
        } catch let error as NSError {
            print(error)
            return .codingError(error)
        }
    }
}
