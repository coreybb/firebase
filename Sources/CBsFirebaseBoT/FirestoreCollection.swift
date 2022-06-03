//
//  FirestoreCollection.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

import FirebaseFirestore

//  TODO: - FIGURE OUT WHAT KIND OF DATA STRUCTURE WE CAN USE TO REGISTER COLLECTIND 
//enum FirestoreCollection: String, Codable, CaseIterable {
//
//    case users = "LSUsers"
//    case interruptions = "Interruptions"
//    case keys = "Keys"
//    case environmentVariables = "EnvironmentVariables"
//    case products = "Products"
//    case companies = "Companies"
//    case keywords = "Keywords"
//    case articles = "Articles"
//    case reviews = "Reviews"
//    case plaidItems = "LSPlaidItems"
//    case plaidAccounts = "LSPlaidAccounts"
//    case plaidTransactions = "LSPlaidTransactions"
//    case plaidInstitutions = "PlaidInstitutions"
//    case matchProducts = "MatchProducts"
//    case people = "People"
//    case concerns = "LSConcerns"
//    case sessions = "Sessions"
//    case searchProducts = "SearchProducts"
//    case pageViews = "PageViews"
//    case events = "Events"
//    case userFeedback = "UserFeedback"
//    case interruptionRelationships = "InterruptionRelationships"
//}
//
//
//extension FirestoreCollection {
//
//    var reference: CollectionReference {
//        return Firestore.firestore().collection(rawValue)
//    }
//}


public struct FirestoreCollection {
    
    
    //----------------------------
    //  MARK: - Public Properties
    //----------------------------
    public var reference: CollectionReference {
        return Firestore.firestore().collection(name)
    }
    public let name: String
    
    
    //---------------
    //  MARK: - Init
    //---------------
    public init(name: String) {
        self.name = name
    }
}
