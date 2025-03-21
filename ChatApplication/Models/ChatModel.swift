//
//  ChatModel.swift
//  ChatApplication
//
//  Created by Anupam on 20/03/25.
//

import Foundation
import CoreLocation
import MessageKit


struct Message: MessageType {
	public var sender: SenderType
	public var messageId: String
	public var sentDate: Date
	public var kind: MessageKind
}

extension MessageKind {
	var messageKindString: String {
		switch self {
		case .text(_):
			return "text"
		case .attributedText(_):
			return "attributed_text"
		case .photo(_):
			return "photo"
		case .video(_):
			return "video"
		case .location(_):
			return "location"
		case .emoji(_):
			return "emoji"
		case .audio(_):
			return "audio"
		case .contact(_):
			return "contact"
		case .custom(_):
			return "customc"
		case .linkPreview(_):
			return "link"
		}
	}
}

struct Sender: SenderType {
	public var photoURL: String
	public var senderId: String
	public var displayName: String

}
