//
//  ProfileViewController.swift
//  ChatApplication
//
//  Created by Anupam on 19/03/25.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	let data = ["Logout"]
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.dataSource = self
		tableView.delegate = self
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate  {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = data[indexPath.row]
		cell.textLabel?.textAlignment = .center
		cell.textLabel?.textColor = .red
		return cell
	}
	
	func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		let actionSheet = UIAlertController(
			title: "",
			message: "",
			preferredStyle: .actionSheet
		)
		actionSheet
			.addAction(
				UIAlertAction(
					title: "Log Out",
					style: .destructive,
					handler: { [weak self] _ in
						guard let strongSelf = self else {
							return
						}
						do {
							try FirebaseAuth.Auth.auth().signOut()
							
							let loginViewController = LoginViewController()
							let nav = UINavigationController(rootViewController: loginViewController)
							nav.modalPresentationStyle = .fullScreen
							strongSelf.present(nav,animated: true)
							
						} catch {
							print("Failed to logout")
						}
						
					}))
		actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		present(actionSheet, animated: true)
	}
}

