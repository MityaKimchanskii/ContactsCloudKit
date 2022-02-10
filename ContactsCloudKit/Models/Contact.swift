//
//  Contact.swift
//  ContactsCloudKit
//
//  Created by Mitya Kim on 2/9/22.
//

import UIKit
import CloudKit

struct StringsContacts {
    
    static let recordTypeKey = "Contact"
    fileprivate static let nameKey = "name"
    fileprivate static let phoneKey = "phone"
    fileprivate static let emailKey = "email"
}

class Contact {
    
    var name: String
    var phone: String
    var email: String
    let recordID: CKRecord.ID
    
    init(name: String, phone: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phone = phone
        self.email = email
        self.recordID = recordID
    }
}

extension Contact {
    
    convenience init?(ckRecord: CKRecord) {
        
        guard let name = ckRecord[StringsContacts.nameKey] as? String,
              let phone = ckRecord[StringsContacts.phoneKey] as? String,
              let email = ckRecord[StringsContacts.emailKey] as? String
        else { return nil }
        
        self.init(name: name, phone: phone, email: email, recordID: ckRecord.recordID)
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

extension CKRecord {
    
    convenience init(contact: Contact) {
        self.init(recordType: StringsContacts.recordTypeKey, recordID: contact.recordID)
        
        self.setValuesForKeys([
            StringsContacts.nameKey: contact.name,
            StringsContacts.phoneKey: contact.phone,
            StringsContacts.emailKey: contact.email
        ])
    }
}
