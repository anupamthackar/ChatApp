//
//  DatabaseManager.swift
//  ChatApplication
//
//  Created by Anupam on 19/03/25.
//

import Foundation
import FirebaseDatabase

struct ChatAppUser {
	let firstName: String
	let lastName: String
	let emailAddress: String
//	let profilePictureUrl: String
}

final class DatabaseManager {
	
	static let shared = DatabaseManager()
	
	private let database = Database.database().reference()
	
}

// MARK: - Account Management
extension DatabaseManager {
	
	public func userExists(with email: String, completion: @escaping (Bool) -> Void) {
		database
			.child(email)
			.observeSingleEvent(of: .value, with: { snapshot in
				guard snapshot.value as? String != nil else {
					completion(false)
					return
				}
				completion(true)
			})
	}
	
	/// Inserts new user to database
	public func insertUser(wiht user: ChatAppUser) {
		database.child(user.emailAddress).setValue([
			"first_name": user.firstName,
			"last_name": user.lastName,
			"email": user.emailAddress
//			"profile_picture": user.profilePictureUrl
		])
	}

}


