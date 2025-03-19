//
//  ViewController.swift
//  ChatApplication
//
//  Created by Anupam on 18/03/25.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		view.backgroundColor = UIColor.red

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		validateAuth()
	}

	private func validateAuth() {
		if FirebaseAuth.Auth.auth().currentUser == nil {
			let loginViewController = LoginViewController()
			let nav = UINavigationController(rootViewController: loginViewController)
			nav.modalPresentationStyle = .fullScreen
			loginViewController.title = "Login"
			present(nav,animated: false)
		}
	}
}

