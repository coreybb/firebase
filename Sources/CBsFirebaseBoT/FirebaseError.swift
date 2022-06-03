//
//  FirebaseError.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

import Foundation


public enum FirebaseError {
    //  TODO: - URGENT: Name these associated values!!!!!
    case badQuery(FirestoreCollection?)
    case duplicateEntry(FirestoreCollection?, String?)
    case firestoreDown
    case geoPointConversionFailure
    case timeout
    case invalidArgument(FirestoreCollection?, String?)
    case noResult(FirestoreCollection?, String?)
    case missingData(FirestoreCollection?, String?)
    case permissions(FirestoreCollection?)
    case serialization([NSError])
    case saveFailure(FirestoreCollection?, String?)
    case unknown(FirestoreCollection?)
}



public extension FirebaseError {
    
    
    var userMessage: String {

        switch self {
        case .duplicateEntry: return "It looks like a record already exists for this item!"
        case .firestoreDown: return "Looks like we're experiencing technical difficulties. Please try again later."
        case .noResult: return "We weren't able to find what you were looking for."
        default: return "Please check your connection and try again later."
        }
    }
    
    
    var logMessage: String {
        
        switch self {
        case .badQuery: return "An invalid query was used."
        case .duplicateEntry: return "You're trying to put something in the database that's already there!"
        case .firestoreDown: return "Firebase is down."
        case .geoPointConversionFailure: return "I wasn't unable to convert any of your addresses into GeoPoints. This is serious!"
        case .timeout: return "A Firebase operation timed out."
        case .invalidArgument: return "Query arguments were structured incorrectly. Show Corey this message so he can fix it!"
        case .noResult: return "I wasn't able to find what you're looking for."
        case .missingData: return "Data was returned from the database, but it's incomplete!"
        case .permissions: return "You don't have permission to do this."
        case .serialization: return "There was a JSON serialization error. Show Corey this message so he can fix it!"
        case .saveFailure: return "I wasn't able to save whatever it is you're trying to save!"
        case .unknown: return "Shit's fucked. Just walk away and go drink. (You should never see this.)"
        }
    }
    
    
    //  TODO: - Shouldn't this just be an enum?
    static func matching(_ code: Int, for collection: FirestoreCollection? = nil, _ objectID: String? = nil) -> FirebaseError {
        
        switch code {
        case 3: return .invalidArgument(collection, objectID)
        case 4: return .timeout
        case 5: return .noResult(collection, objectID)
        case 6: return .duplicateEntry(collection, objectID)
        case 7: return .permissions(collection)
        case 14: return .firestoreDown
        case 15: return .permissions(collection)
        default: return .unknown(collection)
        }
    }
}

