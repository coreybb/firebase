//
//  CBsFirebase.swift
//  
//
//  Created by Corey Beebe on 6/3/22.
//

import Firebase


public class CBsFirebase {
    
    
    //---------------------
    //  MARK: - Public API
    //---------------------
    public func setup() {
        
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        let database = Firestore.firestore()
        database.settings = settings
    }
}
