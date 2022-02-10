//
//  ContactController.swift
//  ContactsCloudKit
//
//  Created by Mitya Kim on 2/9/22.
//

import UIKit
import ClockKit
import CloudKit

class ContactController {
    
    // MARK: - Properties
    static let shared = ContactController()
    var contacts: [Contact] = []
    let publicDB = CKContainer.default().publicCloudDatabase
    
    // MARK: - CRUD
    func saveContact(with name: String, phone: String = "", email: String = "", completion: @escaping (Bool) -> Void) {
        
        let newContact = Contact(name: name, phone: phone, email: email)
        let contactRecord = CKRecord(contact: newContact)
        publicDB.save(contactRecord) { (record, error) in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let record = record,
                  let saveContact = Contact(ckRecord: record)
            else { completion(false); return }

            print("Saved Contact successfully!")
    
            self.contacts.insert(saveContact, at: 0)
        }
    }
    
    func updateContact(_ contact: Contact, name: String, phone: String, email: String, completion: @escaping (Bool) -> Void) {
        
        contact.name = name
        contact.phone = phone
        contact.email = email
        
        let recordToUpdate = CKRecord(contact: contact)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate])
      
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.queuePriority = .high
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let record = records?.first else { completion(false); return }
            print("Updated \(record.recordID.recordName) successfully in CloudKit")
            
            print("Record detail \(record)")
            
            completion(true)
        }
        publicDB.add(operation)
    }
    
    func fetchContact(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: StringsContacts.recordTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            
            guard let records = records else { completion(false); return}
            print("Fetched all Contacts!")
            
            let fetchContacts = records.compactMap { Contact(ckRecord: $0) }
            self.contacts = fetchContacts
            
            completion(true)
        }
    }
    
    func deleteContact(_ contact: Contact, completion: @escaping (Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordIDsToDelete: [contact.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
    
        operation.modifyRecordsResultBlock = { records in
            switch records {
            case .success():
                return completion(true)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(false)
            }
        }
        publicDB.add(operation)
    }
}
