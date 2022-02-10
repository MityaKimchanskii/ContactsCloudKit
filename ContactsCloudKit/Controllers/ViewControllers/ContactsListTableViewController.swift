//
//  ContactsListTableViewController.swift
//  ContactsCloudKit
//
//  Created by Mitya Kim on 2/9/22.
//

import UIKit

class ContactsListTableViewController: UITableViewController {

    // MARK: - Properties
    var contact: Contact? {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViews()
    }
    
    //MARK: - Helper Methods
    func loadData() {
        ContactController.shared.fetchContact { success in
            if success {
                self.updateViews()
            }
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        
        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = contact.phone
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactToDelete = ContactController.shared.contacts[indexPath.row]
            guard let index = ContactController.shared.contacts.firstIndex(of: contactToDelete) else { return }
            
            ContactController.shared.deleteContact(contactToDelete) { success in
                if success {
                    ContactController.shared.contacts.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue",
           let indexPath = tableView.indexPathForSelectedRow,
           let destinationVC = segue.destination as? DetailsContactViewController {
            let contact = ContactController.shared.contacts[indexPath.row]
            destinationVC.contact = contact
        }
    }
}
