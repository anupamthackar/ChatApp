//
//  RegisterViewController.swift
//  ChatApplication
//
//  Created by Anupam on 18/03/25.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
class RegisterViewController: UIViewController {
	// MARK: - Properties
	
	private let spinner = JGProgressHUD(style: .dark)
	
	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(systemName: "person.circle")
		imageView.tintColor = .gray
		imageView.contentMode = .scaleAspectFit
		imageView.layer.masksToBounds = true
		imageView.layer.borderWidth = 2
		imageView.layer.borderColor = UIColor.lightGray.cgColor
		return imageView
	}()
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.clipsToBounds = true
		return scrollView
	}()
	
	private let firstNameField: UITextField = {
		let field = UITextField()
		field.autocapitalizationType = .none
		field.autocorrectionType = .no
		field.returnKeyType = .continue
		field.layer.cornerRadius = 12
		field.layer.borderWidth = 1
		field.layer.borderColor = UIColor.lightGray.cgColor
		field.placeholder = "First Name..."
		field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
		field.leftViewMode = .always
		field.backgroundColor = .white
		return field
	}()
	
	private let lastNameField: UITextField = {
		let field = UITextField()
		field.autocapitalizationType = .none
		field.autocorrectionType = .no
		field.returnKeyType = .continue
		field.layer.cornerRadius = 12
		field.layer.borderWidth = 1
		field.layer.borderColor = UIColor.lightGray.cgColor
		field.placeholder = "Last Name..."
		field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
		field.leftViewMode = .always
		field.backgroundColor = .white
		return field
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
	
	private let registerButton: UIButton = {
		let button = UIButton()
		button.setTitle("Register", for: .normal)
		button.backgroundColor = .systemGreen
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 12
		button.layer.masksToBounds = true
		button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
		return button
	}()
	
	// MARK: - Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		registrationAction()
		setupUI()
		
		// Assign delegates
		delegateCall()
		
		// Add subviews
		addSubviewView()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		viewLayoutSubviews()
	}
}


extension RegisterViewController {
	// MARK: - Actions
	
	@objc private func registerButtonTapped() {
		emailField.resignFirstResponder()
		passwordField.resignFirstResponder()
		firstNameField.resignFirstResponder()
		lastNameField.resignFirstResponder()
		
		guard let first = firstNameField.text, !first.isEmpty,
			  let last = lastNameField.text, !last.isEmpty,
			  let email = emailField.text, !email.isEmpty,
			  let password = passwordField.text, !password.isEmpty, password.count >= 6 else {
			alertUserLoginError()
			return
		}
		spinner.show(in: view)
		UserDefaults.standard.set(email, forKey: "email")
		UserDefaults.standard.set("\(first) \(last)", forKey: "name")
		
		// TODO: - Firebase log in
		DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
			guard let strongSelf = self else { return }
			
			DispatchQueue.main.async {
				strongSelf.spinner.dismiss()
			}
			
			guard !exists else {
				// user already exists
				self?.alertUserLoginError(message: "Looks like a user account for that email address already exists.")
				return
			}
			
			FirebaseAuth.Auth
				.auth()
				.createUser(
					withEmail: email,
					password: password,
					completion: { authResult,error in
						
						guard authResult != nil,
							  error == nil else {
							print("Error creating user")
							return
						}
						
						let user = authResult?.user
						print("Created User: \(user)")
						DatabaseManager.shared
							.insertUser(
								wiht: ChatAppUser(
									firstName: first,
									lastName: last,
									emailAddress: email
								), completion: { _ in }
							)
						
						strongSelf.navigationController?.dismiss(animated: true, completion: nil)
						
					})
		})
	}
	
	@objc private func didTapChangeProfilePic() {
		print("Change profile pic called")
		presentPhotoActionSheet()
	}
	
	func alertUserLoginError(message: String = "Please enter all information to create a new account.") {
		let alert = UIAlertController(
			title: "wooops",
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
		present(alert, animated: true)
	}
}

// MARK: - Text Field Delegate

extension RegisterViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == emailField {
			passwordField.becomeFirstResponder()
		} else if textField == passwordField {
			registerButtonTapped()
		}
		return true
	}
}

// MARK: - Picker & Navigation Delegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func presentPhotoActionSheet() {
		let actionSheet = UIAlertController(
			title: "Profile Picture",
			message: "How would you like to select a picture?",
			preferredStyle: .actionSheet
		)
		
		actionSheet.addAction(UIAlertAction(title: "Cencel",
											style: .cancel,
											handler: nil))
		actionSheet.addAction(UIAlertAction(title: "Take Photo",
											style: .default,
											handler: { [weak self] _ in
			self?.presentCamera()
		}))
		actionSheet.addAction(UIAlertAction(title: "Chose Photo",
											style: .default,
											handler: { [weak self] _ in
			self?.presentPhotoPicker()
		}))
		present(actionSheet, animated: true)
	}
	
	func presentCamera() {
		let vc = UIImagePickerController()
		vc.sourceType = .camera
		vc.delegate = self
		vc.allowsEditing = true
		present(vc, animated: true)
	}
	
	func presentPhotoPicker() {
		let vc = UIImagePickerController()
		vc.sourceType = .photoLibrary
		vc.delegate = self
		vc.allowsEditing = true
		present(vc, animated: true)
	}
	
	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
	) {
		picker.dismiss(animated: true, completion: nil)
//		print(info)
		
		guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
		self.imageView.image = selectedImage
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}


// MARK: - Utility

extension RegisterViewController {
	private func delegateCall() {
		emailField.delegate = self
		passwordField.delegate = self
	}
	
	private func addSubviewView() {
		scrollView.addSubview(imageView)
		scrollView.addSubview(firstNameField)
		scrollView.addSubview(lastNameField)
		scrollView.addSubview(emailField)
		scrollView.addSubview(passwordField)
		scrollView.addSubview(registerButton)
		view.addSubview(scrollView)
	}
	
	private func registrationAction() {
		registerButton
			.addTarget(
				self,
				action: #selector(registerButtonTapped),
				for: .touchUpInside
			)
	}
	
	private func setupUI() {
		view.backgroundColor = .white
		navigationItem.title = "Login"
		imageView.isUserInteractionEnabled = true
		scrollView.isUserInteractionEnabled = true
		let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
		gesture.numberOfTouchesRequired = 1
		imageView.addGestureRecognizer(gesture)
	}
	
	private func viewLayoutSubviews() {
		scrollView.frame = view.bounds
		
		let size = view.width / 3
		imageView.frame = CGRect(x: (view.width - size) / 2,
								 y: 20,
								 width: size,
								 height: size)
		imageView.layer.cornerRadius = imageView.width / 2.0
		firstNameField.frame = CGRect(x: 30,
									  y: imageView.bottom + 10,
									  width: scrollView.width - 60,
									  height: 52)
		lastNameField.frame = CGRect(x: 30,
									 y: firstNameField.bottom + 10,
									 width: scrollView.width - 60,
									 height: 52)
		emailField.frame = CGRect(x: 30,
								  y: lastNameField.bottom + 10,
								  width: scrollView.width - 60,
								  height: 52)
		passwordField.frame = CGRect(x: 30,
									 y: emailField.bottom + 10,
									 width: scrollView.width - 60,
									 height: 52)
		registerButton.frame = CGRect(x: 30,
								   y: passwordField.bottom + 10,
								   width: scrollView.width - 60,
								   height: 52)
		
	}
}
