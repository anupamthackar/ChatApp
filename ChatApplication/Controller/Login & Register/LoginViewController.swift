//
//  LoginViewController.swift
//  ChatApplication
//
//  Created by Anupam on 18/03/25.
//

import UIKit

class LoginViewController: UIViewController {
	// MARK: - Properties
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "logo")
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.clipsToBounds = true
		return scrollView
	}()
	
	private let emailField: UITextField = {
		let field = UITextField()
		field.autocapitalizationType = .none
		field.autocorrectionType = .no
		field.returnKeyType = .continue
		field.layer.cornerRadius = 12
		field.layer.borderWidth = 1
		field.layer.borderColor = UIColor.lightGray.cgColor
		field.placeholder = "Email Address..."
		field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
		field.leftViewMode = .always
		field.backgroundColor = .white
		return field
	}()
	
	private let passwordField: UITextField = {
		let field = UITextField()
		field.autocapitalizationType = .none
		field.autocorrectionType = .no
		field.returnKeyType = .done
		field.layer.cornerRadius = 12
		field.layer.borderWidth = 1
		field.layer.borderColor = UIColor.lightGray.cgColor
		field.placeholder = "Password..."
		field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
		field.leftViewMode = .always
		field.backgroundColor = .white
		field.isSecureTextEntry = true
		return field
	}()
	
	private let loginButton: UIButton = {
		let button = UIButton()
		button.setTitle("Log In", for: .normal)
		button.backgroundColor = .link
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 12
		button.layer.masksToBounds = true
		button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
		return button
	}()
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = .white
		
		navigationItem.title = "Log In"
		navigationItem.rightBarButtonItem = UIBarButtonItem(
			title: "Register",
			style: .done,
			target: self,
			action: #selector(didTapRegister)
		)
		// Assign delegates
		loginButton
			.addTarget(
				self,
				action: #selector(loginButtonTapped),
				for: .touchUpInside
			)
		emailField.delegate = self
		passwordField.delegate = self
		
		// Add subviews
		view.addSubview(scrollView)
		scrollView.addSubview(imageView)
		scrollView.addSubview(emailField)
		scrollView.addSubview(passwordField)
		scrollView.addSubview(loginButton)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		scrollView.frame = view.bounds
		
		let size = view.width / 3
		imageView.frame = CGRect(x: (view.width - size) / 2,
								 y: 20,
								 width: size,
								 height: size)
		emailField.frame = CGRect(x: 30,
								  y: imageView.bottom + 10,
								  width: scrollView.width - 60,
								  height: 52)
		passwordField.frame = CGRect(x: 30,
									 y: emailField.bottom + 10,
									 width: scrollView.width - 60,
									 height: 52)
		loginButton.frame = CGRect(x: 30,
									 y: passwordField.bottom + 10,
									 width: scrollView.width - 60,
									 height: 52)
	}
}

extension LoginViewController {
	// MARK: - Actions
	@objc private func didTapRegister() {
		let registerViewController = RegisterViewController()
		registerViewController.title = "Create Account"
		navigationController?
			.pushViewController(registerViewController, animated: true)
	}
	
	@objc private func loginButtonTapped() {
		emailField.resignFirstResponder()
		passwordField.resignFirstResponder()
		
		guard let email = emailField.text, !email.isEmpty,
			  let password = passwordField.text, !password.isEmpty, password.count >= 6 else {
			alertUserLoginError()
			return
		}
		// TODO: - Firebase log in
		
	}
	
	func alertUserLoginError() {
		let alert = UIAlertController(
			title: "wooops",
			message: "Please enter all information to log in.",
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
		present(alert, animated: true)
	}
}


extension LoginViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailField {
			passwordField.becomeFirstResponder()
		} else if textField == passwordField {
			loginButtonTapped()
		}
		return true
	}
}
