//
//  ConversationsModel.swift
//  ChatApplication
//
//  Created by Anupam on 20/03/25.
//

import Foundation

struct Conversation {
	let id: String
	let name: String
	let otherUserEmail: String
	let latestMessage: LatestMessage
}

struct LatestMessage {
	let date: String
	let text: String
	let isRead: Bool
}
