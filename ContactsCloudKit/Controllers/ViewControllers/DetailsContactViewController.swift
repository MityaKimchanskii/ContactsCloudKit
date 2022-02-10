//
//  DetailsContactViewController.swift
//  ContactsCloudKit
//
//  Created by Mitya Kim on 2/9/22.
//

import UIKit

class DetailsContactViewController: UIViewController {
    
    // MARK: - Properties
    var contact: Contact?
    
    // MARK: - IBOutlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let name = nameTF.text, !name.isEmpty,
              let phone = phoneTF.text,
              let email = emailTF.text
        else { return }
     
        if let contact = contact {
            ContactController.shared.updateContact(contact, name: name, phone: phone, email: email) { success in
                if success {
                    print("The contact successfully updated!")
                }
            }
        } else {
            ContactController.shared.saveContact(with: name, phone: phone, email: email) { success in
                if success {
                    self.dismissView()
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateView() {
        if let contact = contact {
            nameTF.text = contact.name
            phoneTF.text = contact.phone
            emailTF.text = contact.email
            title = "Details"
        } else {
            title = "Add new contact"
        }
    }
}
