//
//  ViewController.swift
//  ChatApplication
//
//  Created by Anupam on 18/03/25.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class ConversationViewController: UIViewController {
	
	private let spinner = JGProgressHUD(style: .dark)
	
	private var conversations = [Conversation]()
	
	@IBOutlet var tableView: UITableView! {
		didSet {
			tableView.isHidden = true
			tableView.register(ConversationTableViewCell.self,
							   forCellReuseIdentifier: ConversationTableViewCell.identifier)
		}
	}
	
	private let noConversationLabel: UILabel = {
		let label = UILabel()
		label.text = "No Conversation"
		label.textAlignment = .center
		label.textColor = .gray
		label.font = .systemFont(ofSize: 21, weight: .medium)
		label.isHidden = true
		return label
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
															target: self,
															action: #selector(didTapComposeButton))
		view.addSubview(noConversationLabel)
		setupTableView()
		fetchConversations()
		startListeningForCOnversations()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		validateAuth()
	}
	
	private func startListeningForCOnversations() {
		guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
			return
		}
		
		print("starting conversation fetch...")

		let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

		DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
			switch result {
			case .success(let conversations):
				print("successfully got conversation models")
				guard !conversations.isEmpty else {
					return
				}
				
				self?.conversations = conversations

				DispatchQueue.main.async {
					self?.tableView.reloadData()
					self?.tableView.layoutIfNeeded()
				}
				
			case .failure(let error):
				
				print("failed to get convos: \(error)")
			}
		})
	}
	
	private func validateAuth() {
		tableView.reloadData()
		if FirebaseAuth.Auth.auth().currentUser == nil {
			let loginViewController = LoginViewController()
			let nav = UINavigationController(rootViewController: loginViewController)
			nav.modalPresentationStyle = .fullScreen
			loginViewController.title = "Login"
			present(nav,animated: false)
		}
	}
	
	@objc private func didTapComposeButton() {
		let vc = NewConversationViewController()
		vc.completion = { [weak self] result in
			self?.createNewConversation(result: result)
		}
		let navVC = UINavigationController(rootViewController: vc)
		present(navVC, animated: true)
	}
	
	private func createNewConversation(result: [String: String]) {
		guard let name = result["name"],
			  let email = result["email"] else {
			return
		}
		
		let vc = ChatViewController(with: email, id: nil)
		vc.isNewConversation = true
		vc.title = name
		vc.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(vc, animated: true)
	}
	
	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	private func fetchConversations() {
		tableView.isHidden = false
	}
}

// MARK: - Table View Delegate
extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return conversations.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let model = conversations[indexPath.row]

		let cell = tableView.dequeueReusableCell(
			withIdentifier: ConversationTableViewCell.identifier,
			for: indexPath ) as! ConversationTableViewCell
		
		cell.configure(with: model)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let model = conversations[indexPath.row]
		
		let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
		vc.title = model.name
		vc.navigationItem.largeTitleDisplayMode = .never
		navigationController?.pushViewController(vc, animated: true)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
}
