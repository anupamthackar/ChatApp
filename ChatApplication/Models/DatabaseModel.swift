//
//  DatabaseModel.swift
//  ChatApplication
//
//  Created by Anupam on 20/03/25.
//

import Foundation

struct ChatAppUser {
	let firstName: String
	let lastName: String
	let emailAddress: String
	var safeEmail: String {
		var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
		safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
		return safeEmail
	}
}



public enum DatabaseError: Error {
	case failedToFetch
}
