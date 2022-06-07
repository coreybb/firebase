//
//  FirestoreNetworking.swift
//  
//
//  Created by Corey Beebe on 6/2/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


public protocol FirestoreNetworking {


    /// Retrieves an array containing entire collection of objects of the specified type from Firestore.
    func getAll <T: Firestorable> (_ collection: FirestoreCollection, complete: NetworkResults<T>?)


    /// Retrieves an array of objects with the specified IDs from a single specified collection.
    func getObjects <T: Decodable> (with ids: [String], from collection: FirestoreCollection, complete: NetworkResults<T>?)


    /// Retrieves a single object with a specified ID from a specified collection.
    func getObject <T: Decodable> (with id: String, from collection: FirestoreCollection, complete: NetworkResult<T>?)


    /// Retrieves an array of objects conforming to any of the parameters defined by multiple Firestore Queries.
    func getObjects <T: Firestorable> (with queries: [Query], complete: NetworkResults<T>?)


    /// Retrieves an array of objects conforming to parameters defined by a Firestore Query.
    func getObjects <T: Firestorable> (with query: Query, complete: NetworkResults<T>?)


    /// Atomically batch writes an array of objects conforming to `IdentifiableByProperty`  to Firestore. If explicitly assigned IDs are required, objects must be assigned these values in advance.
    func batchPut <T: Identifiable & Firestorable> (_ objectsWithID: [T], complete: NetworkResults<T>?)


    /// Saves an object to Firestore. If no `explicitID` value is provided, one will be generated. If a document ID matching the object's ID is required, but `IdentifiableByProperty` conformance is not possible,  an explicitID must be provided.
    func put <T: Firestorable> (_ object: T, explicitID: String?, _ complete: NetworkResult<T>?)


    /// Saves an object conforming to `IdentifiableByProperty` to Firestore. If the object lacks an ID and no `explicitID` value is provided, one will be generated. If the passed object already has a valid ID, `explicitID` will be ignored.
    func put <T: Identifiable> (_ objectWithID: T, explicitID: String?, _ complete: NetworkResult<T>?)
}



//-------------------------
//  MARK: - Implementation
//-------------------------
public extension FirestoreNetworking {


    typealias NetworkResult <T: Firestorable> = (_ result: FirebaseResult<T>) -> ()
    typealias NetworkResults <T: Firestorable> = (_ result: FirebaseResult<[T]>) -> ()
    typealias DecodedObject <T: Firestorable> = (_ result: FirestoreDecodingResult<T>) -> ()



    //---------------------
    //  MARK: - Public API
    //---------------------
    func getAll <T: Firestorable> (_ collection: FirestoreCollection, complete: NetworkResults<T>?) {

        collection.reference.getDocuments {
            (snapshot, error) in

            if let error = self.firebase(error, for: collection) {
                complete?(.error(error))
                return
            }

            guard let snapshot = snapshot else {
                print("Though Firebase did not return a known error, we were unable to safely unwrap the returned Snapshot object.")
                complete?(.error(self.firebase(error) ?? FirebaseError.noResult(nil, nil)))
                return
            }

            var codingErrors: [NSError]?

            guard let objects: [T] = self.decodedObjects(from: snapshot, decodingErrors: &codingErrors),
                  !objects.isEmpty else {

                guard let codingErrors = codingErrors else {
                    complete?(.error(.noResult(nil, nil))); return
                }

                complete?(.error(.serialization(codingErrors))); return
            }
            
            complete?(.object(objects))
        }
    }


    func getObjects <T: Decodable> (with ids: [String], from collection: FirestoreCollection, complete: NetworkResults<T>?) {

        var objects: [T]?
        var caughtError: FirebaseError?
        let dispatchGroup = DispatchGroup()

        ids.forEach {

            dispatchGroup.enter()
            getObject(with: $0, from: collection) {
                (result: FirebaseResult<T>) in
                switch result {
                case .object(let object): if (objects?.append(object)) == nil { objects = [object] }
                case .error(let error): caughtError = error
                }

                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            guard let objects = objects else {
                complete?(.error(caughtError ?? .noResult(collection, nil))); return
            }

            complete?(.object(objects))
        }
    }


    func getObject <T: Decodable> (with id: String, from collection: FirestoreCollection, complete: NetworkResult<T>?) {

        //  TODO: - Handle log mode
//        if isLogMode {
//            print("Retrieving \(id) from \(collection.rawValue).")
//        }

        collection.reference.document(id).getDocument {
            (document, error) in

            guard let document = document else {
                let error = self.firebase(error, for: collection, id) ?? .noResult(collection, id)
                complete?(.error(error))
                return
            }

            switch document.decoded(type: T.self) {
            case .object(let object):
                guard let object = object else {
                    complete?(.error(.unknown(collection))); return
                }
                complete?(.object(object))
            case .codingError(let error):
                complete?(.error(.serialization([error])))
            }
        }
    }


    func getObjects <T: Firestorable> (with queries: [Query], complete: NetworkResults<T>?) {

        var objects: [T]?
        var error: FirebaseError?
        let dispatchGroup = DispatchGroup()

        queries.forEach {

            dispatchGroup.enter()
            getObjects(with: $0) {
                (result: FirebaseResult<[T]>) in

                switch result {
                case .error(let caughtError): error = caughtError
                case .object(let newObjects):
                    if (objects?.append(contentsOf: newObjects)) == nil {
                        objects = newObjects
                    }
                }

                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {

            guard let objects = objects else {
                complete?(.error(error ?? .unknown(nil))); return
            }

            complete?(.object(objects))
        }
    }


    func getObjects <T: Firestorable> (with query: Query, complete: NetworkResults<T>?) {

        query.getDocuments {
            (snapshot, error) in

            guard let snapshot = snapshot else {
                print("NO SNAPSHOT")
                complete?(.error(self.firebase(error) ?? FirebaseError.noResult(nil, nil)))
                return
            }

            var codingErrors: [NSError]?

            guard let objects: [T] = self.decodedObjects(from: snapshot, decodingErrors: &codingErrors),
                  !objects.isEmpty else {

                guard let codingErrors = codingErrors else {
                    complete?(.error(.noResult(nil, nil))); return
                }

                complete?(.error(.serialization(codingErrors))); return
            }

            complete?(.object(objects))
        }
    }


    func batchPut <T: Identifiable & Firestorable> (_ objectsWithID: [T], complete: NetworkResults<T>? = nil) {

        //  TODO: - Figure out how to toggle log mode for the user dev.
//        if isLogMode {
//            print("Batch putting \(objectsWithID.count) object(s) to \(collection)")
//        }

        let batch = Firestore.firestore().batch()
        var codingErrors: [NSError]?

        objectsWithID.forEach {

            do {
                try batch.setData(from: $0, forDocument: T.collection.reference.document($0.id))
            } catch let error as NSError {
                if (codingErrors?.append(error)) == nil {
                    codingErrors = [error]
                }
            }
        }

        batch.commit {

            if let error = self.firebase($0, for: T.collection) {
                complete?(.error(error)); return
            }

            if let codingErrors = codingErrors {
                handleBatch(codingErrors)
            }

            complete?(.object(objectsWithID))
        }
    }


    private func handleBatch(_ codingErrors: [NSError]) {

        print("We ran into some coding errors in trying to perform a batch put. If some objects were able to be successfully encoded, they were probably successfuly persisted.")
        codingErrors.forEach {
            print("\n", $0)
        }
    }


    func put <T: Firestorable> (_ object: T, explicitID: String? = nil, _ complete: NetworkResult<T>? = nil) {

        let id = explicitID ?? T.collection.reference.document().documentID

        do {
            //  TODO: - Does NOT throw an error when it doesn't work. Needs urgent fix.
            try T.collection.reference.document(id).setData(from: object)
            complete?(.object(object))
        } catch let error as NSError {
            //  TODO: - This would likely NOT be a serialization error.
            complete?(.error(.serialization([error])))
        }
    }


    func put <T: Identifiable> (_ objectWithID: T, explicitID: String? = nil, _ complete: NetworkResult<T>? = nil) {

        let object = new(objectWithID, with: explicitID)

        do {
            try T.collection.reference.document(object.id).setData(from: object)
            complete?(.object(object))
        } catch let error as NSError {
            //  TODO: - This would likely NOT be a serialization error.
            complete?(.error(.serialization([error])))
        }
    }


    func search <T: Firestorable> (for term: String, in collection: FirestoreCollection, complete: NetworkResults<T>?) {

        let query = searchQuery(for: term, in: collection)

        query.getDocuments {
            (snapshot, error) in

            if let error = error {
                complete?(.error(.noResult(collection, error.localizedDescription)))
            }

            guard let snapshot = snapshot else {
                complete?(.error(.unknown(collection)))
                return
            }

            let documents = snapshot.documents

            //  TODO: - Extract
            let objects: [T] = documents.compactMap {
                do {
                    return try $0.data(as: T.self)
                } catch let error as NSError {
                    print(error)
                    return nil
                }
            }

            complete?(.object(objects))
        }
    }


    /// NOT INTENDED FOR PRODUCTION USE.
    private func searchQuery(for textInput: String, in collection: FirestoreCollection) -> Query {

        if textInput == "Milford" {

            return collection.reference.whereField("searchName", arrayContains: "milford")
        }

        return collection.reference
                .order(by: "name")
                .start(at: [textInput])
                .end(at: [textInput + "\\ut8ff"])
    }



    //----------------------
    //  MARK: - Private API
    //----------------------
    private func new <T: Identifiable & Firestorable> (_ object: T, with explicitID: String?) -> T {

        var newObject = object

        if newObject.id == "" {
            newObject.id = explicitID ?? T.collection.reference.document().documentID
        }

        return newObject
    }


    private func decodedObjects <T: Firestorable> (from snapshot: QuerySnapshot, decodingErrors: inout [NSError]?) -> [T]? {

        let decodingResults: [FirestoreDecodingResult<T>] = snapshot.documents.compactMap { $0.decoded(type: T.self) }
        let objects: [T]? = decodingResults.compactMap {
            switch $0 {
            case .codingError(let error):
                print(error)
                if (decodingErrors?.append(error) == nil) {
                    decodingErrors = [error]
                }
                return nil
            case .object(let object):
                return object
            }
        }

        if objects.isNilOrEmpty() {
            return nil
        }

        return objects
    }


    func firebase(_ firebaseError: Error?, for collection: FirestoreCollection? = nil, _ objectID: String? = nil) -> FirebaseError? {

        guard let error = firebaseError as NSError? else { return nil }
        return FirebaseError.matching(error.code, for: collection, objectID)
    }
}
