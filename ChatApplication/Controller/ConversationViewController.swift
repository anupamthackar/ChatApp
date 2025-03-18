//
//  ViewController.swift
//  ChatApplication
//
//  Created by Anupam on 18/03/25.
//

import UIKit

class ConversationViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		view.backgroundColor = UIColor.red

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
		
		if !isLoggedIn {
			let loginViewController = LoginViewController()
			let nav = UINavigationController(
				rootViewController: loginViewController
			)
			nav.modalPresentationStyle = .fullScreen
			loginViewController.title = "Login"
			present(nav,animated: false)
		}
	}

}

